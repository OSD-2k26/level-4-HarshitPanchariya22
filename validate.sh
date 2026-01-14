#!/bin/bash
set -e

FILE="artifact.txt"
EXPECTED_CONTENT="THE_TIMELINE_IS_FIXED"

# 1. Commit count (must be at least 4)
COMMIT_COUNT=$(git rev-list --count HEAD)

if [ "$COMMIT_COUNT" -lt 4 ]; then
  echo "❌ Expected at least 4 commits, found $COMMIT_COUNT"
  exit 1
fi

# 2. File must exist
if [ ! -f "$FILE" ]; then
  echo "❌ $FILE does not exist"
  exit 1
fi

# 3. File content must be correct NOW
CURRENT_CONTENT=$(cat "$FILE")

if [ "$CURRENT_CONTENT" != "$EXPECTED_CONTENT" ]; then
  echo "❌ $FILE content is incorrect"
  exit 1
fi

# 4. File must have been broken at some point
BROKEN_COUNT=$(git log -p -- "$FILE" | grep -i "^-.*THE_TIMELINE_IS_FIXED" | wc -l)

if [ "$BROKEN_COUNT" -eq 0 ]; then
  echo "❌ File was never broken in history"
  exit 1
fi

# 5. History must contain a revert-style undo
# (Detects revert by checking identical tree to an earlier commit)
TREE_HASHES=$(git log --format='%T' -- "$FILE")

DUPLICATE_TREE=$(echo "$TREE_HASHES" | sort | uniq -d)

if [ -z "$DUPLICATE_TREE" ]; then
  echo "❌ No proper revert detected (history was rewritten or reset)"
  exit 1
fi

echo "✅ HARD LEVEL A PASSED — Timeline restored correctly"
