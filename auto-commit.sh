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

PROMPT="Write a consise Git commit message in conventional commits format based on the following diff:\n(cat "$TMPDIFF")"

REQUEST_BODY=$(jq -n \
       	--arg model "gpt-4o" \
	--arg content "$PROMPT" \
	'{
	  model: $model,
	  messages: [
	    { role: "user", content: $content }
	  ],
	  max_tokens: 100,
	  temperature: 0.3
	}')


# Call OpenAI
RESPONSE=$(curl -s https://api.openai.com/v1/chat/completions \
   -H "Authorization: Bearer $OPENAI_API_KEY" \
   -H "Content-Type: application/json" \
   -d "$REQUEST_BODY")

#Print raw response for debug
echo "Raw API Response:"
echo "$RESPONSE"

# Extract commit message
COMMIT_MSG=$(echo "$RESPONSE" | jq -r '.choices[0].message.content')


# Final Commit
if [[ -n "$COMMIT_MSG" && "$COMMIT_MSG" != "null" ]]; then
	git commit -m "$COMMIT_MSG"
else
	echo "OpenAI didn't return a valid message. Using fallback."
	git commit -m "feat: dummy commit - AI fallback"
fi

#Cleanup
rm -f "$TMPDIFF"
