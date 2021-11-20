#!/bin/sh
set -eux

DOTFILES=$(cd $(dirname $0)/.. && pwd)

curl -sfLo ${DOTFILES}/rc.d/vim/autoload/plug.vim https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

vim +PlugInstall +qall

if [ ! -f /boot/config.txt ]; then
  cd "${DOTFILES}/rc.d/vim/plugged/YouCompleteMe"
  python3 ./install.py --clang-completer --ts-completer --system-libclang
fi
