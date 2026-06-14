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

# Update safely with --ff-only so no merge commit is created, and only when
# it is actually a git repository.
if [ -d ~/.rbenv/plugins/ruby-build/.git ]; then
  git -C ~/.rbenv/plugins/ruby-build pull --ff-only
fi

eval "$(~/.rbenv/bin/rbenv init -)"
# Ruby has no LTS, so use the latest stable release (4.0 series)
VERSION=4.0.5
# Parallelize make and skip rdoc/ri generation to speed up the build
export MAKE_OPTS="-j$(nproc)"
export RUBY_CONFIGURE_OPTS="--disable-install-doc"
rbenv install -s $VERSION
rbenv global $VERSION
rbenv rehash
