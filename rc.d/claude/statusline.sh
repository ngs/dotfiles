#!/bin/bash
# Claude Code statusline: model / effort / context usage
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name // .model.id // "?"')
EFFORT=$(echo "$input" | jq -r '.effort.level // empty')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // empty' | cut -d. -f1)

out="[$MODEL]"
if [ -n "$EFFORT" ]; then
  case "$EFFORT" in
    high|xhigh|max) out="$out \033[33meffort:${EFFORT}\033[0m" ;;
    *)              out="$out effort:${EFFORT}" ;;
  esac
fi
[ -n "$PCT" ] && out="$out | ctx:${PCT}%"

printf '%b\n' "$out"
