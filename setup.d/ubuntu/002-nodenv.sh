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

# Update safely with --ff-only so no merge commit is created, and only when
# it is actually a git repository.
if [ -d ~/.nodenv/plugins/node-build/.git ]; then
  git -C ~/.nodenv/plugins/node-build pull --ff-only
fi

eval "$(~/.nodenv/bin/nodenv init -)"
# Node.js 24 = Active LTS "Krypton" (supported until 2028-04)
VERSION=24.16.0
# Parallelize make in case a source build happens (node-build normally fetches a prebuilt binary)
export MAKE_OPTS="-j$(nproc)"
nodenv install -s $VERSION
nodenv global $VERSION
nodenv rehash

