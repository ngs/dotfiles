#!/bin/bash
set -eux
###
UNAME=$(uname -s)
TS=$(date +'%Y%m%d%H%M%S')
DOTFILES=$(cd $(dirname $0) && pwd)

for f in $DOTFILES/setup/*.sh ; do
  /bin/sh $f
done

if [ $UNAME == 'Darwin' ]; then
  /bin/sh $DOTFILES/setup/darwin/homebrew.sh
  for f in $DOTFILES/setup/darwin/*.sh ; do
    /bin/sh $f
  done
fi
# teset
