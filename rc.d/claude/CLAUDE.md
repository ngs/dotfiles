# Global Instructions

## Git Rules
- Do NOT run `git commit` or `git push` on your own during normal conversation — wait for explicit user instruction.
- EXCEPTION: when the user invokes an automated flow that includes commit/push as part of its contract (e.g. `/address-review --loop`, `/loop`, or similar skills), treat the invocation itself as authorization and proceed without per-step confirmation.
- ALWAYS specify the remote and branch explicitly when pushing: `git push origin <current-branch>`. Never run a bare `git push` — `push.default` settings vary by machine and a bare push may target the wrong branch (e.g. push `master` instead of the feature branch). Determine the current branch with `git branch --show-current` first if unsure.

## PR / Issue body formatting
- When passing a markdown body via `gh pr create --body "$(cat <<'EOF' ... EOF)"` (or any single-quoted heredoc), DO NOT escape backticks with backslashes. Single-quoted heredocs already suppress shell expansion, so `` `code` `` stays literal; writing `` \`code\` `` produces broken markdown that renders as `` \`code\` `` (with visible backslashes) on GitHub.
- Same rule for `$`, `"`, and other special characters inside `<<'EOF'`: no escaping needed, the single quotes around `EOF` already prevent shell interpretation.
- Quick rule of thumb: if the heredoc opens with `<<'EOF'` (quoted), write the body exactly as it should appear on GitHub. If it opens with `<<EOF` (unquoted), then you need shell escaping — but you should be using the quoted form for prose bodies anyway.
