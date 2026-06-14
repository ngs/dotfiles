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

# merge を作らないよう --ff-only で安全に更新する (git リポジトリのときだけ)
if [ -d ~/.nodenv/plugins/node-build/.git ]; then
  git -C ~/.nodenv/plugins/node-build pull --ff-only
fi

eval "$(~/.nodenv/bin/nodenv init -)"
# Node.js 24 = Active LTS "Krypton" (サポートは 2028-04 まで)
VERSION=24.16.0
# ソースビルドになった場合に make を並列化 (node-build は通常プリビルドバイナリを取得)
export MAKE_OPTS="-j$(nproc)"
nodenv install -s $VERSION
nodenv global $VERSION
nodenv rehash

