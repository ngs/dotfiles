DOTFILES=$(cd $(dirname $0) && pwd)
##
[ `which brew` ] || ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
brew bundle "${DOTFILES}/Brewfile"
brew bundle "${DOTFILES}/Brewfile-kaizen"
##
## Import iTerm 2 Themes
##
for f in $DOTFILES/themes/iterm2/*; do
  THEME=$(basename "$f")
  defaults write -app iTerm 'Custom Color Presets' -dict-add "$THEME" "$(cat "$f")"
done
