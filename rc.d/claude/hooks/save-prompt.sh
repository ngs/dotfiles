#!/bin/bash
# Save prompt in daily summary format
# ~/dotfiles/rc.d/claude/prompts/{project}/{date}.md

INPUT=$(cat)

PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

[ -z "$PROMPT" ] && exit 0

# Save destination
PROMPTS_DIR="$HOME/claude-log"

# Clone if directory doesn't exist
if [ ! -d "$PROMPTS_DIR" ]; then
  git clone git@github.com:ngs/claude-log.git "$PROMPTS_DIR" 2>/dev/null
fi

# Relative path from HOME
PROJECT_PATH="${CWD#$HOME/}"
TODAY=$(date +%Y-%m-%d)
TIME=$(date +%H:%M:%S)

# Commit & push uncommitted files from previous days
(
  cd "$PROMPTS_DIR" || exit 0

  # Detect uncommitted .md files other than today
  OLD_FILES=$(git status --porcelain 2>/dev/null | grep '\.md$' | awk '{print $2}' | grep -v "$TODAY.md")

  if [ -n "$OLD_FILES" ]; then
    echo "$OLD_FILES" | xargs git add
    git commit -m "Add logs before $TODAY" --quiet 2>/dev/null
    git push --quiet 2>/dev/null &
  fi
) &

# Create directory
mkdir -p "$PROMPTS_DIR/$PROJECT_PATH"

# File path
FILE="$PROMPTS_DIR/$PROJECT_PATH/$TODAY.md"

# Add header if file doesn't exist
if [ ! -f "$FILE" ]; then
  echo "# $PROJECT_PATH - $TODAY" > "$FILE"
  echo "" >> "$FILE"
fi

# Append prompt
cat >> "$FILE" << EOF

## $TIME

$PROMPT

---
EOF

exit 0
