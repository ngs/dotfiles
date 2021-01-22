#!/bin/sh

set -eux

sudo apt-get -u update
sudo apt-get -y install vim zsh pinentry-curses direnv jq
[ -f /usr/local/bin/pinentry ] || sudo ln -s /usr/bin/pinentry /usr/local/bin/pinentry

rm ~/.zshrc
