# AGENTS.md

Guide for AI agents working in this repository. It collects repo-specific
gotchas.

## Shell / execution environment

- **The default shell is zsh** (the agent's Bash tool runs under zsh too). Do not
  use `status` as a variable name in scripts — in zsh `status` is read-only and
  assigning to it raises a `read-only variable` error. Use `st` or similar.
- Using `!=` in a `jq` filter gets escaped by zsh to `\!=` and causes a parse
  error. Write it with the `| not` pattern, e.g. `select(.x | . == null | not)`.

## Shell script syntax checking / linting

- `env.sh` and `env.d/**/*.sh` have **no shebang**. They are fragments sourced at
  shell startup and contain bash/zsh syntax (function definitions, `[[ ]]`, etc.),
  so `sh -n` (dash) false-flags them. Check these with `bash -n`.
- CI (the lint job in `.github/workflows/ci.yml`) enumerates every tracked `*.sh`
  via `git ls-files` and decides the interpreter from the shebang: `*bash*` →
  `bash -n`, `#!...sh` → `sh -n`, **no shebang → `bash -n`** (for the sourced
  fragments above).

## *env (language runtimes)

- Version pins are centralized in the `VERSION=` line of each
  `setup.d/ubuntu/00X-*.sh` (nodenv=002 / rbenv=003 / pyenv=004 / goenv=005).
  Change only that file.
- CI asserts that the installed result matches this pin (and fails on mismatch).
  The expected value is extracted from each setup script's `VERSION=` line, so do
  not hardcode it.
- **When verifying versions, run from a neutral directory and don't rely on
  PATH/shims.** `rbenv init -` / `goenv init -` may not prepend shims to PATH, so
  the runner's system ruby/go can win. Also, *env honors a directory-local pin
  (e.g. `.ruby-version`) over the global one — and this repo's root has
  `.ruby-version = system`. CI therefore runs `*env exec` from `$HOME` to check
  the global version that setup installed.
- For repo updates, guard with `[ -d ~/.Xenv/.git ]` and use `git pull --ff-only`
  so a non-git install (package / manual extraction / symlink) doesn't break and
  no unintended merge commit is created.

## GnuPG

- `~/.gnupg` is a symlink to `rc.d/gnupg`. `gpg-agent.conf` is a **generated file
  and is gitignored**. Its sources are `rc.d/gnupg/gpg-agent.conf.linux` /
  `.darwin`, which `setup.d/dotfiles.sh` copies into place per platform. Edit the
  `.linux` / `.darwin` sources, not the generated file. The cache TTL is one year
  (unlock once and it stays cached).
- Commits are GPG-signed (key `036459B1`). The agent's non-tty shell can't run an
  interactive pinentry, so a commit would hang. **At the start of a session, have
  the user run** `echo | gpg --clearsign -u 036459B1 -o /dev/null` **once** to
  cache the passphrase in the agent before doing any commit work.

## dotfiles symlink conventions

- Platform-specific files are managed with a `*.darwin` / `*.linux` suffix;
  `resolve_os_name` in `setup.d/dotfiles.sh` resolves them to the real name per OS.
- Always push with `git push origin <current-branch>` (no bare push).

## Shared agent skills (Claude / Codex / Antigravity)

- **Skills are tool-agnostic** (a folder with a `SKILL.md`, optional `references/`)
  and shared across Claude Code, Codex, and Google Antigravity (`agy`). The single
  source of truth is **`rc.d/agents/skills/<name>/`** — add and edit skills there,
  never in a tool-specific copy.
- Each tool reads the same files through symlinks:
  - **Claude**: `rc.d/claude/skills` is a symlink → `../agents/skills` (committed,
    git mode 120000). `~/.claude/skills` → `rc.d/claude/skills` resolves through it.
  - **`~/.agents`** → `rc.d/agents` is created automatically by the generic
    `for f in rc.d/*` loop (it's not in the exclusion list), giving the
    tool-agnostic `~/.agents/skills/` global location for free.
  - **Codex / Antigravity**: `setup.d/dotfiles.sh` symlinks each skill
    individually into `~/.codex/skills/<name>` and `~/.gemini/config/skills/<name>`
    (guarded on each tool's presence). It links per-skill — not the whole dir — so
    tool-specific siblings (e.g. Codex's `.system`) and externally-managed skills
    are left untouched. `[ -e ]` skips dangling skills (e.g. the `ccskill-gptimage`
    symlink that points at an external `src/` checkout absent on some machines).
- Antigravity (`agy`) reads global skills from **both** `~/.gemini/config/skills/`
  and `~/.gemini/antigravity-cli/skills/`; we use `config/skills/` because it is
  shared by the CLI, IDE, and 2.0. Workspace skills go in `<workspace>/.agents/skills/`.
- `rc.d/codex/config.toml` is symlinked to `~/.codex/config.toml`; the
  machine-local `[projects]` trust entries Codex appends through the symlink are
  kept out of commits by a clean filter (see the clean-filters section below).
  `rc.d/codex/rules/*.rules` are copied once by `setup.d/dotfiles.sh` (only when
  the local file is missing or an old symlink) — Codex appends machine-local
  command approval rules there and no filter covers them, so do not symlink the
  rules. Codex project trust entries are exact worktree paths; do not rely on
  `~/src/*`-style wildcards there.

## Shared global agent instructions (AGENTS.md)

- The global instructions for Claude Code, Codex, and Antigravity are a single
  file: **`rc.d/agents/AGENTS.md`** — edit it there, never a tool-side copy.
- Tool-side files are committed symlinks to it: `rc.d/claude/CLAUDE.md`,
  `rc.d/codex/AGENTS.md`, and `rc.d/gemini/AGENTS.md` all point to
  `../agents/AGENTS.md`, so `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, and
  `~/.gemini/config/AGENTS.md` (a standalone AGENTS.md in an Antigravity
  customization root is loaded as global rules) resolve through them.
  `~/.agents/AGENTS.md` also works via the `~/.agents` → `rc.d/agents` link.
- Keep the content tool-agnostic; a tool-specific rule belongs in the tool's own
  section within the shared file, not in a separate per-tool file.

## Machine-local runtime state in synced configs (git clean filters)

- Some tool configs are symlinked into `~` and the tool writes runtime state
  back through the symlink into the working tree. That state is kept out of
  commits with git clean filters (defined in `rc.d/gitconfig`, wired up in
  `.gitattributes`, scripts in `bin/`):
  - `rc.d/codex/config.toml` → `bin/codex-config-clean` strips `[projects.*]`
    trust entries and `[tui.model_availability_nux]`.
  - `rc.d/gemini/settings.json` → `bin/agy-settings-clean` strips
    `trustedWorkspaces`.
- The working-tree file keeps the full content (it is what the tool reads);
  only the staged/committed blob is cleaned. `git diff` therefore stays quiet
  even though the on-disk file contains machine-local state.
- `rc.d/gemini` (like `claude`, `codex`, `gnupg`) is in the exclusion list of
  the generic `rc.d/*` loop — `~/.gemini` holds runtime state and must never be
  replaced wholesale; `setup.d/dotfiles.sh` links only the reusable pieces.

## This file and CLAUDE.md

- `CLAUDE.md` is a symlink to this `AGENTS.md`. Edit the content on the AGENTS.md
  side.
