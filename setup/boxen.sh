DOTFILES=$(cd $(dirname $0)/../ && pwd)
[ ! -L /opt/rbenv ] && ln -s /opt/boxen/rbenv /opt/rbenv
brew bundle "${DOTFILES}/Brewfiles/boxen"
brew bundle "${DOTFILES}/Brewfiles/fonts"
