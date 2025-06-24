#!/usr/bin/env bash

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

git add .

TMPDIFF=$(mktemp /tmp/gitdiff.XXXXXX)
git diff --cached | head -n 50 > "$TMPDIFF"

if [[ ! -s "$TMPDIFF" ]]; then
	echo "No changes to commit."
    	rm -f "$TMPDIFF"
  	exit 0
fi

echo "feat: dummy commit - AI integration later" > tempmsg.txt
git commit -F tempmsg.txt

rm -f "$TMPDIFF" tempmsg.txt

