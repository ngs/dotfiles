#!/bin/sh
set -eux

ZSH=$HOME/.oh-my-zsh
grep `which zsh` /etc/shells > /dev/null || sudo sh -c 'which zsh >> /etc/shells'
[ -d $ZSH ] || git clone https://github.com/robbyrussell/oh-my-zsh.git $ZSH
