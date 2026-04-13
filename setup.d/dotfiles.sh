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
  symlink "$f" "${HOME}/.gnupg/${LINKNAME}"
done
## Claude Code
ensure_directory "${HOME}/.claude"
for f in $DOTFILES/rc.d/claude/*; do
  BASENAME=$(basename $f)
  resolve_os_name "$BASENAME" || continue
  symlink "$f" "${HOME}/.claude/${LINKNAME}"
done
