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


PROMPT="Write a concise git commit message using conventional commits format based on this diff:\n$(cat "$TMPDIFF")"

#Gemini API Call
RESPONSE=$(curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$GEMINI_API_KEY" \
  -H "Content-Type: application/json" \
  -d @- <<EOF
 {
   "contents": [
     {
       "parts": [
         {
           "text": "$PROMPT"
         }
       ]
     }
  ]
}
EOF
)

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
