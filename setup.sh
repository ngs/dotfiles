#!/bin/bash
###
UNAME=$(uname -s)
TS=$(date +'%Y%m%d%H%M%S')
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
##
## submodule update
##
cd $DOTFILES
git submodule update --init --recursive
gem list -i bundler || sudo gem install bundler
bundle install --path=vendor
cd -
##
## ZShell
##
ZSH=$HOME/.oh-my-zsh
grep `which zsh` /etc/shells > /dev/null || sudo sh -c 'which zsh >> /etc/shells'
[ -d $ZSH ] || git clone https://github.com/robbyrussell/oh-my-zsh.git $ZSH
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
chmod 600 "${HOME}/.ssh/config"
if [ $UNAME == 'Darwin' ]; then
  /bin/sh $DOTFILES/setup/darwin.sh
  /bin/sh $DOTFILES/setup/keyremap4macbook.sh
  /bin/sh $DOTFILES/setup/atom.sh
fi
## GNUPG
ensure_directory "${HOME}/.gnupg"
symlink "${DOTFILES}/rc.d/gpg-agent.conf" "${HOME}/.gnupg/gpg-agent.conf"
symlink "${DOTFILES}/rc.d/gpg.conf" "${HOME}/.gnupg/gpg.conf"

vim +PluginInstall +qall > /dev/null 2>&1

[ -L $DOTFILES/rc.d/vim/bundle/closetag ] || ln -s $DOTFILES/rc.d/vim/bundle/closetag.vim $DOTFILES/rc.d/vim/bundle/closetag

pip install --upgrade -r requirements.txt

