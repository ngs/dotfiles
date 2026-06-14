#!/bin/sh

set -eux

if [ ! -d ~/.goenv ]; then
  git clone https://github.com/syndbg/goenv.git ~/.goenv
  cd ~/.goenv && src/configure && make -C src
fi

# Update to pick up new version definitions. In case it was installed by
# something other than git clone (package manager, manual extraction, symlink,
# etc.), only update when it is a git repository. Use --ff-only so no merge
# commit is created.
if [ -d ~/.goenv/.git ]; then
  git -C ~/.goenv pull --ff-only
fi

export PATH="${HOME}/.goenv/bin:$PATH"
eval "$(~/.goenv/bin/goenv init -)"

# Go has no LTS; the latest two release series are supported, so use the latest stable
VERSION=1.26.4

# goenv install usually fetches a binary so no build runs, but parallelize in case of a source build
export MAKE_OPTS="-j$(nproc)"

goenv install -s $VERSION
goenv global $VERSION
