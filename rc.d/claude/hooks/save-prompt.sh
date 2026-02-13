#!/usr/bin/env bash
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

  # Add all .md files except today's
  find . -name '*.md' -not -name "*$TODAY.md" -type f -exec git add {} + 2>/dev/null

  # Commit if there are staged changes
  if ! git diff --cached --quiet 2>/dev/null; then
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
