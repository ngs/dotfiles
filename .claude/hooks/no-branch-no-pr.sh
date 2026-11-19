#!/usr/bin/env bash
# PreToolUse hook (project-scoped to this dotfiles repo).
# AI agents must commit directly on master here: block creating branches,
# worktrees, pushing to non-master branches, and opening PRs.
# See "Branches and pull requests" in AGENTS.md.

input=$(cat)
tool=$(printf '%s' "$input" | jq -r '.tool_name // ""')
cwd=$(printf '%s' "$input" | jq -r '.cwd // ""')

block() {
  printf 'BLOCKED: %s\nIn this repository AI agents must not create branches or pull requests. Commit directly on master and push with `git push origin master` (see AGENTS.md "Branches and pull requests").\n' "$1" >&2
  exit 2
}

if [ "$tool" = "EnterWorktree" ]; then
  block "worktrees are not used in this repository"
fi
[ "$tool" = "Bash" ] || exit 0

cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // ""')

ws='[[:space:]]'
git_re="(^|$ws)git($ws+-[Cc]$ws+[^[:space:]]+)*$ws+"

# Split compound commands into segments so flags of one command don't leak
# into the check of another.
segments=$(printf '%s\n' "$cmd" | awk '{ gsub(/&&|\|\||;|\|/, "\n"); print }')

while IFS= read -r seg; do
  seg=" $seg "
  if [[ $seg =~ (^|$ws)gh$ws+pr$ws+(create|new)($ws|$) ]]; then
    block "gh pr create"
  fi
  if [[ $seg =~ ${git_re}checkout($ws.*)?$ws(-[bB]|--orphan)($ws|=|$) ]]; then
    block "git checkout -b (branch creation)"
  fi
  if [[ $seg =~ ${git_re}switch($ws.*)?$ws(-[cC]|--create|--force-create|--orphan)($ws|=|$) ]]; then
    block "git switch -c (branch creation)"
  fi
  if [[ $seg =~ ${git_re}branch$ws+[^-[:space:]] ]] ||
     [[ $seg =~ ${git_re}branch($ws.*)?$ws(-[cCf]|--copy|--force-copy|--force|-t|--track|--no-track)($ws|=|$) ]]; then
    block "git branch <name> (branch creation)"
  fi
  if [[ $seg =~ ${git_re}worktree$ws+add($ws|$) ]]; then
    block "git worktree add"
  fi
  if [[ $seg =~ ${git_re}push($ws|$) ]]; then
    # Inspect explicit refspecs: only master (or HEAD / tags) may be pushed.
    rest=${seg#*push}
    read -r -a toks <<<"$rest"
    pos=()
    for t in "${toks[@]}"; do
      case "$t" in -*) ;; *) pos+=("$t") ;; esac
    done
    for ((i = 1; i < ${#pos[@]}; i++)); do
      ref=${pos[i]#+}
      dst=${ref##*:}
      case "$dst" in
        master | HEAD | refs/heads/master | refs/tags/*) continue ;;
      esac
      if [ -n "$cwd" ] && git -C "$cwd" rev-parse -q --verify "refs/tags/$dst" >/dev/null 2>&1; then
        continue
      fi
      block "git push to non-master ref '$dst'"
    done
  fi
done <<<"$segments"

exit 0
