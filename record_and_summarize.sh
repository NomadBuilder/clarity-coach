#!/bin/bash

# === CONFIG ===
MEETING_NAME="$1"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")
FILENAME="${TIMESTAMP}_${MEETING_NAME// /_}"
AUDIO_FILE="${FILENAME}.wav"
OUTPUT_DIR="output_${FILENAME}"
SUMMARY_FILE="${OUTPUT_DIR}/summary_gemini.md"
BULLSHIT_FILE="${OUTPUT_DIR}/bullshit_report.md"
PDF_FILE="${OUTPUT_DIR}/summary_gemini.pdf"

# Load environment variables from .env if present
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Make sure environment variables are set
HUGGING_FACE_TOKEN="$HUGGINGFACEHUB_API_TOKEN"
GEMINI_API_KEY="$GEMINI_API_KEY"

# Validate required environment variables
if [ -z "$HUGGING_FACE_TOKEN" ]; then
  echo "❌ Error: HUGGINGFACEHUB_API_TOKEN environment variable is not set."
  echo "Please add it to your .env file or export it in your shell."
  exit 1
fi

if [ -z "$GEMINI_API_KEY" ]; then
  echo "❌ Error: GEMINI_API_KEY environment variable is not set."
  echo "Please add it to your .env file or export it in your shell."
  exit 1
fi

# === STEP 1: RECORD AUDIO FROM BLACKHOLE ===
echo "🔴 Recording system audio to $AUDIO_FILE ..."
ffmpeg -f avfoundation -i ":BlackHole 2ch" -ac 1 -ar 44100 -t 3600 "$AUDIO_FILE"

# === STEP 2: TRANSCRIBE AND DIARIZE ===
echo "🧠 Running WhisperX for transcription and speaker diarization..."
whisperx "$AUDIO_FILE" --diarize --hf_token "$HUGGING_FACE_TOKEN" --output_dir "$OUTPUT_DIR" --compute_type float32 --device cpu

# === STEP 3: FIND AND RENAME TRANSCRIPT ===
RAW_TRANSCRIPT=$(find "$OUTPUT_DIR" -maxdepth 1 -type f -name "*.txt" | head -n 1)
if [ -f "$RAW_TRANSCRIPT" ]; then
  mv "$RAW_TRANSCRIPT" "${OUTPUT_DIR}/transcription.txt"
  TRANSCRIPT_FILE="${OUTPUT_DIR}/transcription.txt"
else
  TRANSCRIPT_FILE=""
fi

# === STEP 4: SUMMARIZE WITH GEMINI ===
if [ -f "$TRANSCRIPT_FILE" ]; then
  echo "🤖 Calling Gemini API to summarize the meeting..."

  # Core Summary Prompt
  CORE_PROMPT="Create a concise meeting summary with this structure:

## Smart Summary  
Brief overview of the entire meeting.

## Topic Sections  
Divide into titled sections (e.g., Budget, Hiring). Summarize each.

## Key Decisions Made
List the main decisions reached during the meeting.

## Speaker Summary  
Brief summary of each speaker's key contributions and overall tone.

Transcript:"

  # Action Items Prompt
  ACTION_PROMPT="Extract ALL action items from this transcript. Format as:
- [ ] Task description - Assigned to: Name - Due: Date/Timeframe
- [ ] Task description - Assigned to: Name - Due: Date/Timeframe

If no specific assignee or deadline is mentioned, use 'TBD' or 'Not specified'.

Transcript:"

  # Risk Analysis Prompt
  RISK_PROMPT="Analyze this transcript for risks and blockers:

## Risks & Blockers
- **High Risk:** [specific risks with potential impact]
- **Medium Risk:** [moderate concerns]  
- **Blockers:** [immediate obstacles preventing progress]

If none are identified, state 'No significant risks or blockers identified.'

Transcript:"

  # Meeting Assessment Prompt
  ASSESSMENT_PROMPT="Evaluate this meeting's effectiveness:

## Meeting ROI Assessment
- **Time Investment:** [estimate duration from transcript]
- **Key Decisions Made:** [count from transcript]
- **Action Items Created:** [count from transcript]
- **ROI Score:** [1-10 rating with brief justification]

## Follow-up Recommendations
- **Next Meeting:** [purpose and suggested timing]
- **Stakeholders to Include:** [key people needed]
- **Pre-work Required:** [documents or preparation needed]

Transcript:"

  # Generate core summary
  echo "📝 Generating core summary..."
  CORE_PAYLOAD=$(jq -Rs --arg prompt "$CORE_PROMPT" '{"contents": [{"parts": [{"text": ($prompt + .)}]}]}' "$TRANSCRIPT_FILE")
  CORE_SUMMARY=$(curl -s "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$GEMINI_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$CORE_PAYLOAD" | jq -r '.candidates[0].content.parts[0].text')

  # Generate action items
  echo "📋 Extracting action items..."
  ACTION_PAYLOAD=$(jq -Rs --arg prompt "$ACTION_PROMPT" '{"contents": [{"parts": [{"text": ($prompt + .)}]}]}' "$TRANSCRIPT_FILE")
  ACTION_ITEMS=$(curl -s "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$GEMINI_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$ACTION_PAYLOAD" | jq -r '.candidates[0].content.parts[0].text')

  # Generate risk analysis
  echo "⚠️ Analyzing risks and blockers..."
  RISK_PAYLOAD=$(jq -Rs --arg prompt "$RISK_PROMPT" '{"contents": [{"parts": [{"text": ($prompt + .)}]}]}' "$TRANSCRIPT_FILE")
  RISK_ANALYSIS=$(curl -s "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$GEMINI_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$RISK_PAYLOAD" | jq -r '.candidates[0].content.parts[0].text')

  # Generate meeting assessment
  echo "📊 Assessing meeting ROI..."
  ASSESSMENT_PAYLOAD=$(jq -Rs --arg prompt "$ASSESSMENT_PROMPT" '{"contents": [{"parts": [{"text": ($prompt + .)}]}]}' "$TRANSCRIPT_FILE")
  MEETING_ASSESSMENT=$(curl -s "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$GEMINI_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$ASSESSMENT_PAYLOAD" | jq -r '.candidates[0].content.parts[0].text')

  # Combine all sections
  echo "$CORE_SUMMARY" > "$SUMMARY_FILE"
  echo -e "\n\n---\n\n## Action Items & Deadlines\n$ACTION_ITEMS" >> "$SUMMARY_FILE"
  echo -e "\n\n---\n\n$RISK_ANALYSIS" >> "$SUMMARY_FILE"
  echo -e "\n\n---\n\n$MEETING_ASSESSMENT" >> "$SUMMARY_FILE"

  echo "✅ Enhanced Gemini summary saved to: $SUMMARY_FILE"
else
  echo "❌ Transcript not found. Skipping Gemini summarization."
fi

# === STEP 5: RUN BULLSHIT METER ===
echo "🧪 Running bullshit meter..."
if [ -f "$TRANSCRIPT_FILE" ]; then
  python3 bullshit_meter.py "$TRANSCRIPT_FILE" "$BULLSHIT_FILE"
else
  echo "⚠️ No transcript for bullshit meter."
fi

# === STEP 6: COMPLETION NOTIFICATION ===
afplay /System/Library/Sounds/Ping.aiff
osascript -e 'display notification "Meeting summary complete!" with title "AI Recorder"'

# === STEP 7: APPEND BULLSHIT METER REPORT TO SUMMARY ===
if [ -f "$BULLSHIT_FILE" ]; then
  echo -e "\n\n---\n\n## Bullshit Meter Feedback\n" >> "$SUMMARY_FILE"
  cat "$BULLSHIT_FILE" >> "$SUMMARY_FILE"
  echo "💡 Bullshit meter results appended to: $SUMMARY_FILE"
else
  echo "⚠️ No bullshit report found to append."
fi

# === STEP 8: GENERATE PDF ===
echo "📄 Generating PDF report..."
if [ -f "$SUMMARY_FILE" ]; then
  python3 generate_pdf.py "$SUMMARY_FILE" "$PDF_FILE"
  if [ -f "$PDF_FILE" ]; then
    echo "✅ PDF report generated: $PDF_FILE"
  else
    echo "⚠️ PDF generation failed, but markdown summary is available"
  fi
else
  echo "⚠️ No summary file found for PDF generation"
fi

# === STEP 9: OPEN FOLDER AND FILES ===
echo "📂 Opening summary folder..."
open "$OUTPUT_DIR"
if [ -f "$PDF_FILE" ]; then
  open "$PDF_FILE"
elif [ -f "$SUMMARY_FILE" ]; then
  open "$SUMMARY_FILE"
fi

# === STEP 10: SHOW FILE PATHS ===
echo -e "\n📁 Files saved:"
echo "🔊 Audio:       $AUDIO_FILE"
echo "📜 Transcript:  ${OUTPUT_DIR}/transcription.txt"
echo "📝 Summary:     $SUMMARY_FILE"
echo "🧪 Bullshit:    $BULLSHIT_FILE"
echo "📄 PDF Report:  $PDF_FILE"
