#!/bin/sh
DOTFILES=$(cd $(dirname $0)/../.. && pwd)

## Import gpg key
cd ~/Dropbox/Credentials/gpg
./import.sh
cd $DOTFILES
git crypt init || true
git crypt unlock


