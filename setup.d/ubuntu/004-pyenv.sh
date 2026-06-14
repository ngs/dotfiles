#!/bin/sh

set -eux

if [ ! -d ~/.pyenv ]; then
  git clone https://github.com/pyenv/pyenv.git ~/.pyenv
  cd ~/.pyenv && src/configure && make -C src
fi

# Update to pick up new version definitions. In case it was installed by
# something other than git clone (package manager, manual extraction, symlink,
# etc.), only update when it is a git repository. Use --ff-only so no merge
# commit is created.
if [ -d ~/.pyenv/.git ]; then
  git -C ~/.pyenv pull --ff-only
fi

# `pyenv init -` output invokes the pyenv command itself, so put it on PATH first
export PATH="${HOME}/.pyenv/bin:$PATH"
eval "$(~/.pyenv/bin/pyenv init -)"

# Python has no LTS, so use the latest stable release (3.14 series, supported until 2030-10)
VERSION=3.14.6

# Parallelize make to speed up the build
export MAKE_OPTS="-j$(nproc)"
export PYTHON_CONFIGURE_OPTS="--enable-shared"

pyenv install -s $VERSION
pyenv global $VERSION
