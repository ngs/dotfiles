#!/bin/bash
set -eux
###
UNAME=$(uname -s)
TS=$(date +'%Y%m%d%H%M%S')
DOTFILES=$(cd $(dirname $0) && pwd)

cd $DOTFILES
git submodule init
git submodule update
cd -

set +u
if [ $CODESPACES ]; then
  /bin/sh $DOTFILES/setup.d/codespaces/apt.sh
fi
set -u

for f in $DOTFILES/setup.d/*.sh ; do
  /bin/sh $f
done

if [ $UNAME == 'Darwin' ]; then
  /bin/sh $DOTFILES/setup.d/darwin/homebrew.sh
  for f in $DOTFILES/setup.d/darwin/*.sh ; do
    /bin/sh $f
  done
fi
