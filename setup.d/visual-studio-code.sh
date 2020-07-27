#!/bin/sh
set -eux

DOTFILES=$(cd $(dirname $0)/.. && pwd)
VSCODE_FILE="${DOTFILES}/VSCodefile"

if [ -d '/Applications/Visual Studio Code.app' ]; then

  cat $VSCODE_FILE | while read -r EXT; do
    code --install-extension $EXT
  done

  code --list-extensions > $VSCODE_FILE

  if [ -d "${HOME}/Library" ]; then
    mkdir -p "${HOME}/Library/Application Support"
    rm -rf "${HOME}/Library/Application Support/Code/User"
    ln -s "${DOTFILES}/rc.d/vscode/userdata" "${HOME}/Library/Application Support/Code/User"
  fi

fi
