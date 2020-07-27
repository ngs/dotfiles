#!/bin/sh

set -eux

apt-get -u update
apt-get -y install vim zsh pinentry-curses
[ -f /usr/local/bin/pinentry ] || ln -s /usr/bin/pinentry /usr/local/bin/pinentry

chsh -s /bin/zsh
