#!/bin/bash
set -eux

DOTFILES=$(cd $(dirname $0)/.. && pwd)
UNAME=$(uname -s)

# OS suffix for platform-specific files (*.darwin, *.linux)
case "$UNAME" in
  Darwin) OS_SUFFIX="darwin" ;;
  Linux)  OS_SUFFIX="linux" ;;
  *)      OS_SUFFIX="" ;;
esac

###
symlink() {
  cd $HOME
  ORG=$1
  DST=$2
  echo "Symlinking: ${ORG} -> ${DST}"
  rm -rf $DST
  ln -s $ORG $DST
  cd - >/dev/null 2>&1
}
ensure_directory() {
  if [ ! -d $1 ]; then
    echo "Making directory: ${1}"
    mkdir -p $1
  fi
}
# Resolve OS-specific suffix. Sets LINKNAME and returns 0 to proceed, 1 to skip.
resolve_os_name() {
  local name=$1
  case "$name" in
    *.darwin)
      [ "$OS_SUFFIX" = "darwin" ] || return 1
      LINKNAME="${name%.darwin}"
      ;;
    *.linux)
      [ "$OS_SUFFIX" = "linux" ] || return 1
      LINKNAME="${name%.linux}"
      ;;
    *)
      LINKNAME="$name"
      ;;
  esac
  return 0
}

for f in $DOTFILES/rc.d/*; do
  BASENAME=$(basename $f)
  if [ $BASENAME != 'subversion' ] && [ $BASENAME != 'sbt' ] && [ $BASENAME != 'ssh' ] && [ $BASENAME != 'cmus' ] && [ $BASENAME != 'karabiner' ] && [ $BASENAME != 'claude' ] && [ $BASENAME != 'gh' ] && [ $BASENAME != 'gnupg' ]; then
    resolve_os_name "$BASENAME" || continue
    rm -rf "${HOME}/${LINKNAME}"
    symlink "$f" "${HOME}/.${LINKNAME}"
  fi
done
## Subversion
ensure_directory "${HOME}/.subversion"
symlink "${DOTFILES}/rc.d/subversion/config" "${HOME}/.subversion/config"
## SSH
ensure_directory "${HOME}/.ssh"
symlink "${DOTFILES}/rc.d/ssh/config" "${HOME}/.ssh/config"
chmod 600 "${HOME}/.ssh/config"
## SSH
ensure_directory "${HOME}/.sbt/0.13/plugins"
symlink "${DOTFILES}/rc.d/sbt/0.13/plugins/build.sbt" "${HOME}/.sbt/0.13/plugins/build.sbt"
## Karabiner Elements
ensure_directory "${HOME}/.config"
symlink "${DOTFILES}/rc.d/karabiner" "${HOME}/.config/karabiner"
symlink "${DOTFILES}/rc.d/gh" "${HOME}/.config/gh"
symlink "${DOTFILES}/rc.d/cmus" "${HOME}/.config/cmus"
## GnuPG
ensure_directory "${HOME}/.gnupg"
for f in "$DOTFILES/rc.d/gnupg"/*; do
  [ ! -f "$f" ] && continue
  BASENAME=$(basename "$f")
  case "$BASENAME" in
    *.conf|*.conf.darwin|*.conf.linux) ;;
    *) continue ;;
  esac
  resolve_os_name "$BASENAME" || continue
  echo "Copying: ${f} -> ${HOME}/.gnupg/${LINKNAME}"
  cp "$f" "${HOME}/.gnupg/${LINKNAME}"
done
## Claude Code
ensure_directory "${HOME}/.claude"
for f in $DOTFILES/rc.d/claude/*; do
  BASENAME=$(basename $f)
  resolve_os_name "$BASENAME" || continue
  symlink "$f" "${HOME}/.claude/${LINKNAME}"
done
## Shared agent skills (Codex / Google Antigravity)
# The real skills live in rc.d/agents/skills. Claude reads them via the
# rc.d/claude/skills -> ../agents/skills symlink (and ~/.agents -> rc.d/agents is
# created by the generic loop above). Codex and Antigravity keep their own skills
# dir holding tool-specific entries (e.g. Codex's .system), so we symlink each
# shared skill individually instead of replacing the whole dir. Skip dangling
# skills such as an external src checkout that isn't present on this machine.
link_shared_skills() {
  local dest=$1 name
  ensure_directory "$dest"
  for s in "${DOTFILES}/rc.d/agents/skills"/*; do
    [ -e "$s" ] || continue
    name=$(basename "$s")
    echo "Symlinking skill: ${s} -> ${dest}/${name}"
    rm -rf "${dest}/${name}"
    ln -s "$s" "${dest}/${name}"
  done
}
# Codex (~/.codex/skills; .system and unrelated skills are left untouched)
if [ -d "${HOME}/.codex" ]; then
  link_shared_skills "${HOME}/.codex/skills"
fi
# Google Antigravity / agy (config/skills is read by the CLI, IDE and 2.0)
if [ -d "${HOME}/.gemini" ]; then
  link_shared_skills "${HOME}/.gemini/config/skills"
fi
