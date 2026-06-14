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

## This file and CLAUDE.md

- `CLAUDE.md` is a symlink to this `AGENTS.md`. Edit the content on the AGENTS.md
  side.
