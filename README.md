# 🎯 Clarity Coach

> **Transform your meetings into actionable insights with AI-powered recording, transcription, and clarity analysis.**

An intelligent meeting assistant that automatically records, transcribes, and analyzes your meetings to improve communication clarity and extract maximum value from every conversation.

## 🚀 **Core Features**

### **🎯 Smart Recording & Transcription**
- **System Audio Capture** - Records directly from BlackHole audio driver
- **AI-Powered Transcription** - WhisperX with speaker diarization
- **Multi-format Output** - SRT, VTT, JSON, and plain text formats

### **🧠 Intelligent Meeting Analysis**
- **Multi-Aspect Summary** - 4 focused AI calls for comprehensive coverage
- **Action Item Extraction** - Automatic task identification with assignees and deadlines
- **Risk Assessment** - Proactive identification of blockers and potential issues
- **Meeting ROI Analysis** - Effectiveness scoring and time investment evaluation
- **Follow-up Recommendations** - Smart suggestions for next meetings and stakeholders

### **💬 Communication Clarity Analysis**
- **Clarity Coach** - Analyzes jargon, filler words, and communication effectiveness
- **Speaker-by-Speaker Breakdown** - Individual communication clarity scores
- **Meeting Dynamics** - Interruption patterns, speaker dominance, and alignment analysis
- **Clarity Improvement Suggestions** - Actionable feedback for better future communication

## 🎨 **Enhanced Output Structure**

Your meeting analysis includes:

### **📋 Business Intelligence**
- **Smart Summary** - Concise overview of key points
- **Topic Sections** - Organized discussion breakdown
- **Key Decisions Made** - Clear decision tracking
- **Action Items & Deadlines** - Structured task management
- **Risks & Blockers** - Proactive issue identification
- **Meeting ROI Assessment** - Effectiveness metrics and scoring

### **👥 Communication Insights**
- **Speaker Summary** - Individual contribution analysis
- **Communication Clarity Scores** - Clarity and effectiveness ratings
- **Filler Word Analysis** - Quantified communication patterns
- **Meeting Dynamics** - Interaction and engagement patterns
- **Clarity Improvement Recommendations** - Actionable communication tips

### **📅 Strategic Planning**
- **Follow-up Recommendations** - Next meeting suggestions
- **Stakeholder Identification** - Key people for future discussions
- **Pre-work Requirements** - Preparation needed for follow-ups

## 🛠️ **Prerequisites**

- **macOS** - Uses BlackHole for audio capture
- **Python 3.11+** - For AI processing and analysis
- **ffmpeg** - Audio processing and conversion
- **BlackHole audio driver** - System audio capture

## 📦 **Installation**

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd Recorder
   ```

2. **Install BlackHole audio driver**
   ```bash
   brew install blackhole-2ch
   ```

3. **Install ffmpeg**
   ```bash
   brew install ffmpeg
   ```

4. **Set up Python environment**
   ```bash
   python3.11 -m venv whisperx-311-env
   source whisperx-311-env/bin/activate
   pip install python-dotenv weasyprint markdown
   pip install git+https://github.com/m-bain/whisperX.git
   ```

## 🔑 **Environment Variables Setup**

This project requires API keys for Gemini and Hugging Face. These should be stored in a `.env` file in the project root (not committed to git).

### **Required API Keys**

- **Gemini API Key** - For intelligent meeting analysis and summarization
- **Hugging Face API Token** - For WhisperX transcription and speaker diarization

### **Setup Instructions**

1. **Create your `.env` file:**
   ```bash
   cp .env.example .env
   ```

2. **Add your API keys:**
   ```
   GEMINI_API_KEY=your-gemini-api-key-here
   HUGGINGFACEHUB_API_TOKEN=your-huggingface-api-key-here
   ```

3. **Get your API keys:**
   - **Gemini API Key**: [Google AI Studio](https://makersuite.google.com/app/apikey)
   - **Hugging Face API Key**: [Hugging Face Settings](https://huggingface.co/settings/tokens)

### **Security Notes**
- ✅ `.env` file is automatically ignored by git
- ✅ All API calls use environment variables
- ✅ No hard-coded secrets in the codebase

## 🚀 **Usage**

### **Quick Start (Recommended)**
```bash
./launch_recorder.sh
```
Prompts for meeting name and starts recording automatically.

### **Manual Recording**
```bash
./record_and_summarize.sh "Meeting Name"
```
Direct recording with specified meeting name.

### **Standalone Analysis**
```bash
python3 bullshit_meter.py path/to/transcript.txt path/to/output.md
```
Analyze existing transcripts for communication quality.

### **Workflow Overview**
1. **Record** - System audio captured via BlackHole
2. **Transcribe** - WhisperX processes audio with speaker identification
3. **Analyze** - 4 focused AI calls generate comprehensive insights
4. **Report** - Combined analysis with business and communication insights

## 📁 **Output Files**

### **Generated Files**
- **🔊 Audio Recording** - `YYYY-MM-DD_HH-MM_Meeting_Name.wav`
- **📜 Transcript** - `output_*/transcription.txt` (with speaker diarization)
- **📝 Enhanced Summary** - `output_*/summary_gemini.md` (comprehensive analysis)
- **📄 PDF Report** - `output_*/summary_gemini.pdf` (beautiful, shareable PDF)
- **💬 Clarity Analysis** - `output_*/bullshit_report.md` (communication insights)

### **Additional Formats**
- **SRT Subtitles** - `output_*/Meeting_Name.srt`
- **VTT Subtitles** - `output_*/Meeting_Name.vtt`
- **JSON Data** - `output_*/Meeting_Name.json` (structured transcript data)
- **TSV Format** - `output_*/Meeting_Name.tsv` (tab-separated values)

## 🔧 **Troubleshooting**

### **Common Issues**

- **Missing API Keys** - Ensure your `.env` file is properly configured
- **Audio Issues** - Check that BlackHole is installed and selected as audio input
- **WhisperX Errors** - Verify your Hugging Face API key has the necessary permissions
- **Model Access** - Accept terms for gated Hugging Face models (pyannote/segmentation-3.0)

### **Performance Tips**

- **Recording Quality** - Ensure good audio input for better transcription
- **Meeting Length** - Longer meetings may take more processing time
- **System Resources** - Close other applications during processing for better performance

## 🛡️ **Security & Privacy**

- ✅ **API Keys** - Stored securely in environment variables
- ✅ **Audio Files** - Processed locally, not uploaded to external services
- ✅ **Transcripts** - Generated locally with your own API keys
- ✅ **Git Safety** - Sensitive files automatically ignored

## 🎯 **Why This Tool is Awesome**

### **🤖 AI-Powered Intelligence**
- **4-Focused Analysis** - Multiple AI calls for comprehensive coverage
- **Smart Action Extraction** - Automatic task identification and assignment
- **Risk Proactive Detection** - Identifies potential issues before they become problems
- **Communication Clarity Scoring** - Quantified feedback on meeting effectiveness

### **⚡ Productivity Boost**
- **Zero Manual Work** - Fully automated from recording to analysis
- **Immediate Insights** - Get actionable feedback right after meetings
- **Structured Output** - Ready-to-use summaries and action items
- **Historical Tracking** - Build a database of meeting insights over time

### **🎨 Professional Quality**
- **Meeting ROI Assessment** - Understand the value of your time investment
- **Speaker Analysis** - Individual contribution and communication clarity
- **Strategic Recommendations** - Smart suggestions for follow-up meetings
- **Beautiful PDF Reports** - Professional, shareable PDFs with styling and iconography
- **Multi-format Output** - Choose the format that works best for your workflow

### **🔒 Enterprise Ready**
- **Secure by Design** - No data leaves your system
- **API Key Management** - Professional environment variable handling
- **Error Handling** - Graceful failure and recovery
- **Extensible Architecture** - Easy to add new analysis features 