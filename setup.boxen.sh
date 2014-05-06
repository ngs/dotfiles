DOTFILES=$(cd $(dirname $0) && pwd)
brew bundle "${DOTFILES}/Brewfiles/boxen"
brew bundle "${DOTFILES}/Brewfiles/fonts"

