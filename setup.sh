#!/bin/bash
###
UNAME=$(uname -s)
TS=$(date +'%Y%m%d%H%M%S')
DOTFILES=$(cd $(dirname $0) && pwd)
DOTATOM="${HOME}/.atom"
DOTATOM_BK="${HOME}/_atom-${TS}"
ATOM_CACHE="${DOTATOM}/compile-cache"
ATOM_CACHE_BK="${DOTATOM_BK}/compile-cache"
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
##
## submodule update
##
cd $DOTFILES
git submodule update --init --recursive
cd -
##
## ZShell
##
ZSH=$HOME/.oh-my-zsh
grep `which zsh` /etc/shells > /dev/null || sudo sh -c 'which zsh >> /etc/shells'
[ -d $ZSH ] || git clone https://github.com/robbyrussell/oh-my-zsh.git $ZSH
##
## Backup .atom
[ -d $DOTATOM ] && [ ! -L $DOTATOM ] && mv $DOTATOM $DOTATOM_BK
##
## Symlink
##
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
## Move .atom compile-cache
if [ -d $ATOM_CACHE_BK ] && [ ! -d $ATOM_CACHE ]; then
  echo "Moving: ${ATOM_CACHE_BK} ${ATOM_CACHE}"
  mv $ATOM_CACHE_BK $ATOM_CACHE
fi
if [ $UNAME == 'Darwin' ]; then
  if [ -f /opt/boxen/env.sh ]; then
    /bin/sh $DOTFILES/setup.boxen.sh
  else
    /bin/sh $DOTFILES/setup.darwin.sh
  fi
fi
