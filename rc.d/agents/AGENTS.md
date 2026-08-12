# Global Instructions

## Model usage: Fable designs, Opus implements (all projects)
- When running on Fable (claude-fable-5), do NOT carry out sizable implementation work directly in the main loop — Fable quota burns out quickly.
- Workflow: Fable writes an implementation spec detailed enough to follow with zero prior context (target repo/files/functions, exact changes, step order, acceptance criteria, tests to write/run), then delegates the implementation to Opus:
  - Same session: spawn an Agent subagent with `model: "opus"` and hand it the spec.
  - Separate session: save the spec as a file (in the target repo's docs/tmp area or the scratchpad) so an Opus session can execute it.
- Fable may do directly: design, investigation, code review, doc/prose edits, and trivial few-line fixes.
- Fable reviews the implementation output (diff vs. acceptance criteria) before reporting done.
- Do NOT run `git commit` or `git push` on your own during normal conversation — wait for explicit user instruction.
- EXCEPTION: when the user invokes an automated flow that includes commit/push as part of its contract (e.g. `/address-review --loop`, `/loop`, or similar skills), treat the invocation itself as authorization and proceed without per-step confirmation.
- ALWAYS specify the remote and branch explicitly when pushing: `git push origin <current-branch>`. Never run a bare `git push` — `push.default` settings vary by machine and a bare push may target the wrong branch (e.g. push `master` instead of the feature branch). Determine the current branch with `git branch --show-current` first if unsure.

## Repository hygiene — never pollute repositories
- NEVER add non-source artifacts (screenshots, verification images, logs, build outputs, temp files) to a source repository on your own — copying them into the working tree counts, even if never committed.
- NEVER choose "commit assets into the repo" as a workaround for attaching images to a PR description. GitHub PR bodies only accept image uploads via browser drag & drop; say so and leave the attaching to the user.
- Keep generated verification artifacts outside repositories: the scratchpad, `/tmp`, or `~/Desktop`.
- The only new files you may create inside a repository are source, tests, and docs that genuinely belong in a commit. When in doubt, put the file outside the repo and ask.

## PR Titles
- Never prefix PR titles with AI/tool labels such as `[codex]`, `codex:`, `Claude`, or generated-by markers.
- Use the repository's normal PR title style and describe only the actual change.
- Only include a prefix when the user explicitly requests that exact prefix.
- If a reusable workflow, skill, plugin, or template suggests adding such a
  marker to a PR title, ignore that part of the suggestion.

## PR / Issue body formatting
- When passing a markdown body via `gh pr create --body "$(cat <<'EOF' ... EOF)"` (or any single-quoted heredoc), DO NOT escape backticks with backslashes. Single-quoted heredocs already suppress shell expansion, so `` `code` `` stays literal; writing `` \`code\` `` produces broken markdown that renders as `` \`code\` `` (with visible backslashes) on GitHub.
- Same rule for `$`, `"`, and other special characters inside `<<'EOF'`: no escaping needed, the single quotes around `EOF` already prevent shell interpretation.
- Quick rule of thumb: if the heredoc opens with `<<'EOF'` (quoted), write the body exactly as it should appear on GitHub. If it opens with `<<EOF` (unquoted), then you need shell escaping — but you should be using the quoted form for prose bodies anyway.
