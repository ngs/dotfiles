#!/bin/sh

set -eux

sudo apt-get -u update
sudo apt-get -y install build-essential libssl-dev libc6 cmake python3.8-dev vim zsh pinentry-curses direnv jq libyaml-dev
[ -f /usr/local/bin/pinentry ] || sudo ln -s /usr/bin/pinentry /usr/local/bin/pinentry

