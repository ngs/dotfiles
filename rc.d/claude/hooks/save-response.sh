#!/usr/bin/env bash
# Append response to daily summary
# Executed by Stop hook

INPUT=$(cat)

TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

[ -z "$TRANSCRIPT_PATH" ] || [ ! -f "$TRANSCRIPT_PATH" ] && exit 0

# Save destination
PROMPTS_DIR="$HOME/claude-log"

# Clone if directory doesn't exist
if [ ! -d "$PROMPTS_DIR" ]; then
  git clone git@github.com:ngs/claude-log.git "$PROMPTS_DIR" 2>/dev/null
fi

# Set up union merge for markdown files to avoid conflicts
if [ ! -f "$PROMPTS_DIR/.gitattributes" ]; then
  echo '*.md merge=union' > "$PROMPTS_DIR/.gitattributes"
fi

# Pull latest changes (in background to avoid blocking)
(
  cd "$PROMPTS_DIR" || exit 0
  git add -A 2>/dev/null
  git stash --quiet 2>/dev/null
  git pull --rebase --quiet 2>/dev/null || {
    git rebase --abort 2>/dev/null
    git pull --quiet 2>/dev/null || true
  }
  git stash pop --quiet 2>/dev/null || true
) &

# Relative path from HOME
PROJECT_PATH="${CWD#$HOME/}"
TODAY=$(date +%Y-%m-%d)
TIME=$(date +%H:%M:%S)

# File path
FILE="$PROMPTS_DIR/$PROJECT_PATH/$TODAY.md"

# Skip if file doesn't exist
[ ! -f "$FILE" ] && exit 0

# Extract the last assistant message containing text
RESPONSE=$(tac "$TRANSCRIPT_PATH" 2>/dev/null | while IFS= read -r line; do
  TYPE=$(echo "$line" | jq -r '.type // empty' 2>/dev/null)
  if [ "$TYPE" = "assistant" ]; then
    TEXT=$(echo "$line" | jq -r '[.message.content[]? | select(.type == "text") | .text] | join("\n")' 2>/dev/null)
    if [ -n "$TEXT" ] && [ "$TEXT" != "null" ] && [ "$TEXT" != "" ]; then
      printf '%s' "$TEXT"
      break
    fi
  fi
done)

[ -z "$RESPONSE" ] && exit 0

# Append response
{
  echo ""
  echo "### Response ($TIME)"
  echo ""
  echo "$RESPONSE"
  echo ""
  echo "---"
} >> "$FILE"

exit 0
