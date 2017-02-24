#!/bin/sh
DOTFILES=$(cd $(dirname $0)/../.. && pwd)
##
[ `which brew` ] || ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew update
brew tap Homebrew/bundle
brew bundle --file="${DOTFILES}/Brewfiles/default"
brew bundle --file="${DOTFILES}/Brewfiles/fonts"
brew bundle --file="${DOTFILES}/Brewfiles/casks"
brew bundle --file="${DOTFILES}/Brewfiles/mas"

