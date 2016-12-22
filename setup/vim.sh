#!/bin/sh

DOTFILES=$(cd $(dirname $0)/.. && pwd)

vim +PluginInstall +GoInstallBinaries +qall > /dev/null 2>&1
[ -L $DOTFILES/rc.d/vim/bundle/closetag ] || ln -s $DOTFILES/rc.d/vim/bundle/closetag.vim $DOTFILES/rc.d/vim/bundle/closetag
