#!/bin/sh
set -eux

DOTFILES=$(cd $(dirname $0)/.. && pwd)

curl -sfLo ${DOTFILES}/rc.d/vim/autoload/plug.vim https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

vim +PlugInstall +qall

cd "${DOTFILES}/rc.d/vim/plugged/YouCompleteMe"
python3 install.py --all


