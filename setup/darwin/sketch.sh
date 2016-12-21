#!/bin/sh
DOTFILES=$(cd $(dirname $0)/../.. && pwd)

##
## Import Sketch presets
##
for f in $DOTFILES/ide/sketch/*; do
  cat $f > ~/Library/Containers/com.bohemiancoding.sketch3/Data/Library/Application\ Support/com.bohemiancoding.sketch3/$(basename "$f")
done

