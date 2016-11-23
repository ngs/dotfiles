DOTFILES=$(cd $(dirname $0)/.. && pwd)

##
[ `which brew` ] || ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew tap Homebrew/bundle
brew bundle --file="${DOTFILES}/Brewfiles/default"
# brew bundle --file="${DOTFILES}/Brewfiles/kaizen"
brew bundle --file="${DOTFILES}/Brewfiles/fonts"

## Import gpg key
cd ~/Dropbox/Credentials/gpg
./import.sh
cd $DOTFILES
git crypt init || true
git crypt unlock

##
## Import iTerm 2 Themes
##
for f in $DOTFILES/themes/iterm2/*; do
  THEME=$(basename "$f")
  defaults write -app iTerm 'Custom Color Presets' -dict-add "$THEME" "$(cat "$f")"
done

[ -e ~/Documents/tomorrow-theme ] || /bin/sh -c 'git clone git@github.com:chriskempson/tomorrow-theme.git ~/Documents/tomorrow-theme'

##
## Import Sketch presets
##
for f in $DOTFILES/ide/sketch/*; do
  cat $f > ~/Library/Containers/com.bohemiancoding.sketch3/Data/Library/Application\ Support/com.bohemiancoding.sketch3/$(basename "$f")
done

##
## Install Alcatraz
##
[ -d "${HOME}/Library/Application Support/Developer/Shared/Xcode/Plug-ins/Alcatraz.xcplugin" ] || curl -fsSL https://raw.github.com/alcatraz/Alcatraz/master/Scripts/install.sh | sh

##
## Setup Finder
##
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder NewWindowTarget -string "PfHm" && \
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}"

###
### SSH Agent Startup https://github.com/jirsbek/SSH-keys-in-macOS-Sierra-keychain
###
SSH_ADD_A_PLIST=$HOME/Library/LaunchAgents/ssh-add-a.plist
[ -f $SSH_ADD_A_PLIST ] && sudo chown $USER $SSH_ADD_A_PLIST
cat ${DOTFILES}/setup/ssh-add-a.plist > $SSH_ADD_A_PLIST
sudo chown root $SSH_ADD_A_PLIST
sudo launchctl load $SSH_ADD_A_PLIST
