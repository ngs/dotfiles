#!/bin/sh

set -eux

if [ ! -d ~/.pyenv ]; then
  git clone https://github.com/pyenv/pyenv.git ~/.pyenv
  cd ~/.pyenv && src/configure && make -C src
fi

# 新しいバージョン定義を取得するため更新する
git -C ~/.pyenv pull

eval "$(~/.pyenv/bin/pyenv init -)"

# Python に LTS はないため最新安定版を使用 (3.14 系、サポートは 2030-10 まで)
VERSION=3.14.6

# make を並列化してビルドを高速化
export MAKE_OPTS="-j$(nproc)"
export PYTHON_CONFIGURE_OPTS="--enable-shared"

pyenv install -s $VERSION
pyenv global $VERSION
