# CommitSense 🚀

CommitSense is a smart shell-based Git commit automation tool that uses **Google Gemini 1.5 Flash** to generate commit messages based on your code changes.

## ✨ Features

- 🔥 Auto-generates commit messages from `git diff`
- ✍️ Follows [Conventional Commits](https://www.conventionalcommits.org/)
- 🤖 Uses Gemini AI (via API)
- ⏰ Supports Cron automation
- 🛡️ Fallback message if AI fails

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
   ```
2. Set your Gemini API Key:
   ```bash
   export GEMINI_API_KEY="your-api-key-here"
   ```
3. Make the script executable:
   ```bash
   chmod +x auto-commit.sh
   ```
## ▶️ Usage

Run the script inside your Git project:

```bash
./auto-commit.sh
```

## ⏰ Cron Job Automation
To automatically commit changes daily at 10:00 PM:
```bash
crontab -e
```

Then add this line (replace /home/your-username with your actual path):
```cron
0 22 * * * /home/your-username/commitsense/auto-commit.sh >> /home/your-username/commitsense/auto-commit.log 2>&1
```

To stop the cron job:
```bash
crontab -r
```

## Troubleshooting
API errors? Ensure your GEMINI_API_KEY is valid and not expired.

Permission denied? Run chmod +x auto-commit.sh

Nothing commits? Ensure you have modified files and staged changes before running the script.

## 📄 License  
MIT License. Feel free to use, fork, and improve!
