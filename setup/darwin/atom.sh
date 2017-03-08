#!/bin/sh

DOTFILES=$(cd $(dirname $0)/../.. && pwd)

apm install --packages-file "${DOTFILES}/Atomfile"
apm upgrade --confirm=false
apm list -bi > "${DOTFILES}/Atomfile"

##
## Set Atom as default text editor
##
defaults write com.apple.LaunchServices LSHandlers -array-add '{LSHandlerContentType=public.plain-text;LSHandlerRoleAll=com.github.atom;}'


