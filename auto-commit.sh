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
DIFF_CONTENT=$(cat "$TMPDIFF")

PROMPT="Write a consise commit message for this code diff:\n$DIFF_CONTENT"

JSON_PAYLOAD=$(jq -n --arg prompt "$PROMPT" '{
  contents: [
    {
      role: "user",
      parts: [
        { text: $prompt }
      ]
    }
  ]
}')


#Gemini API Call
RESPONSE=$(curl -s -X POST \
   "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$GEMINI_API_KEY" \
   -H "Content-Type: application/json" \
   -d "$JSON_PAYLOAD")

#Print raw response for debug
echo "Raw API Response:"
echo "$RESPONSE"

# Extract commit message
COMMIT_MSG=$(echo "$RESPONSE" | jq -r '.candidates[0].content.parts[0].text // empty')


# Final Commit
if [[ -n "$COMMIT_MSG" ]]; then
	git commit -m "$COMMIT_MSG"
else
	echo "Gemini didn't return a valid message. Using fallback."
	git commit -m "feat: dummy commit - AI fallback"
fi

#Cleanup
rm -f "$TMPDIFF"
