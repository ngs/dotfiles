# Global Instructions

Shared global instructions for every agent runtime (Claude Code, Codex,
Antigravity). Keep this file to two kinds of content: **boundaries** (what you
must not decide on your own) and **facts** (conventions you cannot infer from
the code in front of you). Nothing here is a nudge to try harder.

## Language by repository visibility

- In PUBLIC repositories (this dotfiles repo and other personal public repos): write EVERYTHING in English — commit messages, PR titles/bodies, issues, code comments, and docs.
- Work-organization repositories keep their existing convention (Japanese commit messages / PR bodies).
- When unsure, check `gh repo view --json visibility` before committing.

## Git — what needs explicit permission

- Do NOT run `git commit` or `git push` on your own during normal conversation — wait for explicit user instruction.
- EXCEPTION: when the user invokes an automated flow that includes commit/push as part of its contract (e.g. `/address-review --loop`, `/loop`, or similar skills), treat the invocation itself as authorization and proceed without per-step confirmation.
- ALWAYS specify the remote and branch explicitly when pushing: `git push origin <current-branch>`. Never run a bare `git push` — `push.default` settings vary by machine and a bare push may target the wrong branch (e.g. push `master` instead of the feature branch). Determine the current branch with `git branch --show-current` first if unsure.

## Model usage: Fable designs, Opus implements (all projects)

- When running on Fable (`claude-fable-5`), do NOT carry out sizable implementation work directly in the main loop — Fable quota burns out quickly.
- Instead write an implementation spec detailed enough to follow with zero prior context (target repo/files/functions, exact changes, step order, acceptance criteria, tests to write/run), then delegate it: an Agent subagent with `model: "opus"` in the same session, or a spec file (the target repo's docs/tmp area, or the scratchpad) for a separate Opus session.
- Fable may do directly: design, investigation, code review, doc/prose edits, and trivial few-line fixes — and reviews the delegated diff against the acceptance criteria before reporting done.

## Repository hygiene — never pollute repositories

- NEVER add non-source artifacts (screenshots, verification images, logs, build outputs, temp files) to a source repository on your own — copying them into the working tree counts, even if never committed.
- NEVER commit assets into a repository as a way to get images into a PR description. Keep generated verification artifacts outside repositories: the scratchpad, `/tmp`, or `~/Desktop`.
- The only new files you may create inside a repository are source, tests, and docs that genuinely belong in a commit. When in doubt, put the file outside the repo and ask.

## No private-repo details in public dotfiles

- The files under `~/.claude/` (settings.json, CLAUDE.md, hooks, skills) are symlinks into this PUBLIC dotfiles repository. Never write anything there that mentions or describes a private repository: repo names, org names, internal domains, infrastructure details, locations of sensitive data, or repo-specific permission/deny rules.
- When a setup flow (e.g. `/auto-mode-setup`) generates settings content that is specific to a private repository, put it in that repository's `.claude/settings.local.json` (gitignored) instead of the user-level settings.json. If it was already written to the user-level file, move it out before the dotfiles change is committed.
- Knowledge or instructions specific to a private repository belong in that repository's own `CLAUDE.md` (committed there, synced via its git), never in this global file.
- Before committing in this repository, scan the diff for private repo/org references and strip or relocate them.

## PR titles

- Never prefix PR titles with AI/tool labels such as `[codex]`, `codex:`, `Claude`, or generated-by markers — including when a reusable workflow, skill, plugin, or template suggests one. Ignore that part of the suggestion.
- Use the repository's normal PR title style and describe only the actual change. Include a prefix only when the user explicitly requests that exact prefix.

## PR / issue body formatting

- Inside a single-quoted heredoc (`gh pr create --body "$(cat <<'EOF' ... EOF)"`), write the body exactly as it should render on GitHub — no backslash escaping of backticks, `$`, or quotes. The quotes around `EOF` already suppress shell expansion, and escaping there leaks visible backslashes into the rendered markdown. Use the quoted form for prose bodies.
