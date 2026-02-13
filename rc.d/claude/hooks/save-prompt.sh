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

# Set up union merge for markdown files to avoid conflicts
if [ ! -f "$PROMPTS_DIR/.gitattributes" ]; then
  echo '*.md merge=union' > "$PROMPTS_DIR/.gitattributes"
fi

# Pull latest changes and clean up any conflict markers
(
  cd "$PROMPTS_DIR" || exit 0
  git pull --rebase --quiet 2>/dev/null || {
    # If rebase fails, abort and try merge
    git rebase --abort 2>/dev/null
    git pull --quiet 2>/dev/null || true
  }
  # Remove conflict markers from all .md files
  find . -name '*.md' -type f -exec sed -i '' \
    -e '/^<<<<<<< /d' \
    -e '/^=======/d' \
    -e '/^>>>>>>> /d' {} + 2>/dev/null
) &

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
