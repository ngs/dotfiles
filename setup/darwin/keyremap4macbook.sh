#!/bin/sh
DOTFILES=$(cd $(dirname $0)/../.. && pwd)

cli=/Applications/Karabiner.app/Contents/Library/bin/karabiner
$cli set repeat.wait 10
$cli set repeat.initial_wait 200
