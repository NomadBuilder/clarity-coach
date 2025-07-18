import os
import json
import requests
import re
from collections import Counter
from dotenv import load_dotenv
load_dotenv()

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
MODEL = "gemini-2.0-flash"
GEMINI_URL = f"https://generativelanguage.googleapis.com/v1beta/models/{MODEL}:generateContent?key={GEMINI_API_KEY}"

# Validate required environment variables
if not GEMINI_API_KEY:
    raise ValueError("GEMINI_API_KEY environment variable is not set. Please add it to your .env file or export it in your shell.")

BULLSHIT_PROMPT = """
You are a professional communication analyst evaluating a meeting transcript for clarity and effectiveness.

Instructions:
1. Identify vague, overused, or meaningless business jargon (e.g., "circle back", "synergy", "touch base").
2. Rate the **overall meeting clarity** from 1 (vague) to 10 (clear and productive).
3. For **each speaker** (e.g., SPEAKER_00), do the following:
   - Quote 1–2 examples of vague, repetitive, or filler language they used.
   - **List the filler words they used and estimate counts** (e.g., "um", "like", "you know").
   - Rate their individual clarity from 1–10.
   - Note any patterns of repetition or tangents.
   - Provide constructive suggestions to improve future communication.
4. Comment on **meeting dynamics**:
   - Were there **interruptions** or overlapping dialogue? If yes, by whom?
   - Was one speaker **dominant**, or was talk-time balanced?

5. Conclude with a brief improvement report:
   - Overall meeting clarity score
   - Top 3 jargon phrases to avoid
   - 3 specific suggestions to improve meeting effectiveness

Format the entire output in clean, well-structured **Markdown**.

Transcript:
{transcript}
"""

def extract_speaker_filler_counts(transcript):
    filler_words = ["like", "you know", "um", "uh", "i mean", "sort of", "kind of", "just", "basically", "so", "and so"]
    speakers = {}
    for line in transcript.strip().splitlines():
        match = re.match(r"(SPEAKER_\\d+):\\s*(.*)", line)
        if match:
            speaker = match.group(1)
            text = match.group(2).lower()
            if speaker not in speakers:
                speakers[speaker] = []
            speakers[speaker].append(text)

    filler_report = {}
    for speaker, lines in speakers.items():
        combined_text = " ".join(lines)
        counter = Counter()
        for word in filler_words:
            pattern = r'\\b' + re.escape(word) + r'\\b'
            matches = re.findall(pattern, combined_text)
            if matches:
                counter[word] += len(matches)
        if counter:
            filler_report[speaker] = dict(counter)
    return filler_report

def run_bullshit_meter(transcript_path: str, output_path: str):
    with open(transcript_path, "r") as f:
        transcript = f.read()

    filler_counts = extract_speaker_filler_counts(transcript)

    payload = {
        "contents": [
            {
                "parts": [
                    {"text": BULLSHIT_PROMPT.format(transcript=transcript)}
                ]
            }
        ]
    }

    headers = {"Content-Type": "application/json"}
    response = requests.post(GEMINI_URL, headers=headers, data=json.dumps(payload))
    data = response.json()

    try:
        text = data["candidates"][0]["content"]["parts"][0]["text"]
    except Exception as e:
        text = f"[Error parsing Gemini response]\\n{e}\\n\\nFull response:\\n{json.dumps(data, indent=2)}"

    # Append filler word analysis
    if filler_counts:
        text += "\\n\\n---\\n\\n## Filler Word Analysis\\n"
        for speaker, counts in filler_counts.items():
            text += f"\\n**{speaker}**\\n"
            for word, count in counts.items():
                text += f"- {word}: {count}\\n"

    with open(output_path, "w") as out:
        out.write(text)

    print(f"Bullshit report saved to: {output_path}\\n")
    print("--- Quick Preview ---")
    print("\\n".join(text.strip().split("\\n")[:6]))


if __name__ == "__main__":
    import sys
    if len(sys.argv) != 3:
        print("Usage: python bullshit_meter.py path/to/transcript.txt path/to/output.md")
    else:
        run_bullshit_meter(sys.argv[1], sys.argv[2])