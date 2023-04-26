#!/bin/sh

set -eux

if [ ! -d ~/.rbenv ]; then
  git clone https://github.com/rbenv/rbenv.git ~/.rbenv
  cd ~/.rbenv && src/configure && make -C src
fi

mkdir -p ~/.rbenv/plugins
if [ ! -d ~/.rbenv/plugins/ruby-build ]; then
  git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
fi

cd ~/.rbenv/plugins/ruby-build
git pull

eval "$(~/.rbenv/bin/rbenv init -)"
VERSION=3.2.2
rbenv install -s $VERSION
rbenv global $VERSION
rbenv rehash
