#!/bin/sh
DOTFILES=$(cd $(dirname $0)/../.. && pwd)

## Import gpg key
cd ~/Dropbox/Credentials/gpg
/bin/sh ./import.sh
