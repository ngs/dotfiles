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
# Ruby に LTS はないため最新安定版を使用 (4.0 系)
VERSION=4.0.5
# make を並列化し、rdoc/ri の生成をスキップしてビルドを高速化
export MAKE_OPTS="-j$(nproc)"
export RUBY_CONFIGURE_OPTS="--disable-install-doc"
rbenv install -s $VERSION
rbenv global $VERSION
rbenv rehash
