#!/bin/zsh
cd ~/desktop/AIModules/Recorder

# Ask for meeting name
MEETING_NAME=$(osascript -e 'Tell application "System Events" to display dialog "Enter meeting name:" default answer ""' -e 'text returned of result' 2>/dev/null)

if [ -z "$MEETING_NAME" ]; then
  echo "❌ No meeting name provided. Exiting."
  exit 1
fi

source whisperx-311-env/bin/activate
./record_and_summarize.sh "$MEETING_NAME"
