#!/bin/sh
DOTFILES=$(cd $(dirname $0)/../.. && pwd)
##
## Import iTerm 2 Themes
##
for f in $DOTFILES/themes/iterm2/*; do
  THEME=$(basename "$f")
  defaults write -app '/usr/local/Caskroom/iterm2/2.0/iTerm.app' 'Custom Color Presets' -dict-add "$THEME" "$(cat "$f")"
done

[ -e ~/Documents/tomorrow-theme ] || /bin/sh -c 'git clone git@github.com:chriskempson/tomorrow-theme.git ~/Documents/tomorrow-theme'

