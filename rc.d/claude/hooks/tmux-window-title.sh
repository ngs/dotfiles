#!/usr/bin/env bash
# Claude Code SessionStart hook: while Claude Code runs inside tmux, keep the
# window name synced to Claude Code's terminal title — an auto-generated
# summary of the current task that updates as the conversation evolves —
# instead of the version-number default. Implemented with window-local tmux
# options so tmux tracks the title live with no further hook invocations.
# The SessionEnd hook in settings.json unsets them to restore normal naming.

[ -n "$TMUX" ] && [ -n "$TMUX_PANE" ] || exit 0

# #{=22:...} truncates by cell width: 22 cells is roughly 10 CJK characters.
tmux set-option -w -t "$TMUX_PANE" automatic-rename-format '#{=22:pane_title}' 2>/dev/null
tmux set-option -w -t "$TMUX_PANE" automatic-rename on 2>/dev/null
exit 0
