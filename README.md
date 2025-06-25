# CommitSense 🚀

CommitSense is a smart shell-based Git commit automation tool that uses **Google Gemini 1.5 Flash** to generate commit messages based on your code changes.

## ✨ Features

- 🔥 Auto-generates commit messages from `git diff`
- ✍️ Follows [Conventional Commits](https://www.conventionalcommits.org/)
- 🤖 Uses Gemini AI (via API)
- ⏰ Supports Cron automation
- 🛟 Fallback message if AI fails

## 🛠️ Requirements

- `bash` (Linux/macOS)
- `git` (installed & initialized)
- `jq` (JSON processor)
- A valid **Gemini API key** (Google AI Studio)

## 🔧 Setup

1. Clone the repo:
   ```bash
   git clone https://github.com/ShreyaSumanPatnaik/commitsense.git
   cd commitsense
   
