#!/bin/sh

set -eux

if [ ! -d ~/.goenv ]; then
  git clone https://github.com/syndbg/goenv.git ~/.goenv
  cd ~/.goenv && src/configure && make -C src
fi

export PATH="${HOME}/.goenv/bin:$PATH"
eval "$(~/.goenv/bin/goenv init -)"

VERSION=1.19.8

goenv install -s $VERSION
goenv global $VERSION
