#!/usr/bin/env bash

set -euo pipefail

# Load your config file where the API key and model are set
source "${HOME}/.gitmsghookrc"

cd "$(git rev-parse --show-toplevel)"

git add .

TMPDIFF=$(mktemp /tmp/gitdiff.XXXXXX)
git diff --cached | head -n "${MAX_DIFF_LINES:-200}" > "$TMPDIFF"

if [[ ! -s "$TMPDIFF" ]]; then
	echo "No changes to commit."
    	rm -f "$TMPDIFF"
  	exit 0
fi

#Create an AI prompt
read -r -d '' PROMPT <<EOF || true
You are a helpful assistant that writes Conventional Commits messages.
Based on this diff, produce a one-line subject and a short body.

$(cat "$TMPDIFF")
EOF

# Ask OpenAI for a commit message
AI_RESPONSE=$(curl -s https://api.openai.com/v1/chat/completions \
   -H "Authorization: Bearer $OPENAI_API_KEY" \
   -H "Content-Type: application/json" \
   -d @- <<JSON
{
"model": "$MODEL",
"messages": [
{ "role": "user", "content": $(printf '%q' "$PROMPT") }
],
"max_tokens": 150,
"temperature": 0.3
}
JSON
)

# Extract commit message from API response
COMMIT_MSG=$(printf '%s' "$AI_RESPONSE" | jq -r '.choices[0].message.content')

# Use it for git commit
git commit -m "$COMMIT_MSG"

# Cleanup
rm -f "$TMPDIFF"
