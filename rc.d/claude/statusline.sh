#!/bin/bash
# Claude Code statusline: dir / model / effort / context usage / session id
input=$(cat)

DIR=$(echo "$input" | jq -r '(.workspace.current_dir // .cwd // "") | split("/") | last')
MODEL=$(echo "$input" | jq -r '.model.display_name // .model.id // "?"')
EFFORT=$(echo "$input" | jq -r '.effort.level // empty')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // empty' | cut -d. -f1)
SID=$(echo "$input" | jq -r '.session_id // empty')

out=""
[ -n "$DIR" ] && out="\033[36m${DIR}\033[0m "
out="$out[$MODEL]"
if [ -n "$EFFORT" ]; then
  case "$EFFORT" in
    high|xhigh|max) out="$out \033[33meffort:${EFFORT}\033[0m" ;;
    *)              out="$out effort:${EFFORT}" ;;
  esac
fi
[ -n "$PCT" ] && out="$out | ctx:${PCT}%"
[ -n "$SID" ] && out="$out | \033[90m${SID}\033[0m"

printf '%b\n' "$out"
