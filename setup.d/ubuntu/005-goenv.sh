#!/bin/sh

set -eux

if [ ! -d ~/.goenv ]; then
  git clone https://github.com/syndbg/goenv.git ~/.goenv
  cd ~/.goenv && src/configure && make -C src
fi

# 新しいバージョン定義を取得するため更新する
git -C ~/.goenv pull

export PATH="${HOME}/.goenv/bin:$PATH"
eval "$(~/.goenv/bin/goenv init -)"

# Go に LTS はなく最新 2 系列がサポート対象のため最新安定版を使用
VERSION=1.26.4

# goenv install は通常バイナリ取得のためビルドは走らないが、ソースビルド時に備えて並列化
export MAKE_OPTS="-j$(nproc)"

goenv install -s $VERSION
goenv global $VERSION
