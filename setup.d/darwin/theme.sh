#!/bin/sh
DOTFILES=$(cd $(dirname $0)/../.. && pwd)
#
[ -e ~/Dropbox/tomorrow-theme ] || /bin/sh -c 'git clone git@github.com:chriskempson/tomorrow-theme.git ~/Dropbox/tomorrow-theme'

for f in ~/Dropbox/tomorrow-theme/OS\ X\ Terminal/*.terminal; do
  THEME=$(basename "$f")
  THEME=${THEME%.terminal}
  defaults write com.apple.Terminal "Window Settings" -dict-add "${THEME}" "$(cat "$f")"
done
