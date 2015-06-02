DOTFILES=$(cd $(dirname $0)/.. && pwd)
##
[ `which brew` ] || ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew tap Homebrew/bundle
brew bundle --file="${DOTFILES}/Brewfiles/default"
# brew bundle --file="${DOTFILES}/Brewfiles/kaizen"
brew bundle --file="${DOTFILES}/Brewfiles/fonts"
##
## Import iTerm 2 Themes
##
for f in $DOTFILES/themes/iterm2/*; do
  THEME=$(basename "$f")
  defaults write -app iTerm 'Custom Color Presets' -dict-add "$THEME" "$(cat "$f")"
done
