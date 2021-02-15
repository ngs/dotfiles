#!/bin/sh
DOTFILES=$(cd $(dirname $0)/../.. && pwd)

###
### SSH Agent Startup https://github.com/jirsbek/SSH-keys-in-macOS-Sierra-keychain
###
SSH_ADD_A_PLIST=$HOME/Library/LaunchAgents/ssh-add-a.plist
[ -f $SSH_ADD_A_PLIST ] && sudo chown $USER $SSH_ADD_A_PLIST
cat ${DOTFILES}/setup.d/darwin/ssh-add-a.plist > $SSH_ADD_A_PLIST
sudo chown root $SSH_ADD_A_PLIST
sudo launchctl load $SSH_ADD_A_PLIST
