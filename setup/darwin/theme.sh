#!/bin/sh
DOTFILES=$(cd $(dirname $0)/../.. && pwd)
##
## Import iTerm 2 Themes
#

for app in $(find /usr/local/Caskroom/iterm2 -name 'iTerm.app'); do
  for f in $DOTFILES/themes/iterm2/*; do
    THEME=$(basename "$f")
    defaults write -app $app 'Custom Color Presets' -dict-add "$THEME" "$(cat "$f")"
  done
done

[ -e ~/Dropbox/tomorrow-theme ] || /bin/sh -c 'git clone git@github.com:chriskempson/tomorrow-theme.git ~/Dropbox/tomorrow-theme'

for f in ~/Dropbox/tomorrow-theme/OS\ X\ Terminal/*.terminal; do
  THEME=$(basename "$f")
  THEME=${THEME%.terminal}
  defaults write com.apple.Terminal "Window Settings" -dict-add "${THEME}" "$(cat "$f")"
done
