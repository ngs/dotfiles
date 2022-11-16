#!/bin/sh
DOTFILES=$(cd $(dirname $0)/../.. && pwd)
export ACCEPT_EULA='Y'
##
[ `which brew` ] || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew update
brew tap Homebrew/bundle
brew bundle --file="${DOTFILES}/Brewfiles/default" -vd
brew bundle --file="${DOTFILES}/Brewfiles/fonts" -vd
brew bundle --file="${DOTFILES}/Brewfiles/casks" -vd
brew bundle --file="${DOTFILES}/Brewfiles/mas" -vd

