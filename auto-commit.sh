#!/usr/bin/env bash

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

git add .

TMPDIFF=$(mktemp /tmp/gitdiff.XXXXXX)
git diff --cached | head -n 100 > "$TMPDIFF"

if [[ ! -s "$TMPDIFF" ]]; then
    echo "No changes to commit."
    rm -f "$TMPDIFF"
    exit 0
fi
PROMPT="Generate a short and clear git commit message using the Conventional Commits format based on the following diff:\n$(cat "$TMPDIFF")"
PROMPT_JSON=$(jq -n --arg text "$PROMPT" '{
  contents: [
    {
	    role: "user",
	    parts: [{ text: $text }]
    }
  ]
}')


RESPONSE=$(curl -s -X POST \
   "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY" \
   -H "Content-Type: application/json" \
   -d "$PROMPT_JSON")

#Print raw response for debug
echo "Raw API Response:"
echo "$RESPONSE"

# Extract commit message
COMMIT_MSG=$(echo "$RESPONSE" | jq -r '.candidates[0].content.parts[0].text')


# Final Commit
if [[ -n "$COMMIT_MSG" && "$COMMIT_MSG" != "null" ]]; then
	git commit -m "$COMMIT_MSG"
else
	echo "Gemini didn't return a valid message. Using fallback."
	git commit -m "feat: dummy commit - AI fallback"
fi

#Cleanup
rm -f "$TMPDIFF"
