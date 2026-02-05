#!/bin/sh

set -eux

if [ ! -d ~/.nodenv ]; then
  git clone https://github.com/nodenv/nodenv.git ~/.nodenv
  cd ~/.nodenv && src/configure && make -C src
fi

mkdir -p ~/.nodenv/plugins
if [ ! -d ~/.nodenv/plugins/node-build ]; then
  git clone https://github.com/nodenv/node-build.git ~/.nodenv/plugins/node-build
fi

cd ~/.nodenv/plugins/node-build
git pull

eval "$(~/.nodenv/bin/nodenv init -)"
VERSION=18.16.0
nodenv install -s $VERSION
nodenv global $VERSION
nodenv rehash

