#!/bin/sh
DOTFILES=$(cd $(dirname $0)/../.. && pwd)

## Import gpg key
cd ~/Dropbox/Credentials/gpg
./import.sh
