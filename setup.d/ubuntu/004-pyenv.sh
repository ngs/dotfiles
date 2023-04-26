#!/bin/sh

set -eux

if [ ! -d ~/.pyenv ]; then
  git clone https://github.com/pyenv/pyenv.git ~/.pyenv
  cd ~/.pyenv && src/configure && make -C src
fi

eval "$(~/.nodenv/bin/pyenv init -)"

VERSION=3.11.3

pyenv install -s $VERSION
pyenv global $VERSION
