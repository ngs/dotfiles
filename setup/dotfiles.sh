#!/bin/bash

DOTFILES=$(cd $(dirname $0) && pwd)
###
symlink() {
  cd $HOME
  ORG=$1
  DST=$2
  echo "Symlinking: ${ORG} -> ${DST}"
  rm -f $DST
  ln -s $ORG $DST
  cd - >/dev/null 2>&1
}
ensure_directory() {
  if [ ! -d $1 ]; then
    echo "Making directory: ${1}"
    mkdir -p $1
  fi
}

for f in $DOTFILES/rc.d/* ; do
  BASENAME=$(basename $f)
  if [ $BASENAME != 'subversion' ] && [ $BASENAME != 'ssh' ]; then
    rm -rf "${HOME}/${BASENAME}"
    symlink $f "${HOME}/.$(basename $f)"
  fi
done
## Subversion
ensure_directory "${HOME}/.subversion"
symlink "${DOTFILES}/rc.d/subversion/config" "${HOME}/.subversion/config"
## SSH
ensure_directory "${HOME}/.ssh"
symlink "${DOTFILES}/rc.d/ssh/config" "${HOME}/.ssh/config"
chmod 600 "${HOME}/.ssh/config"