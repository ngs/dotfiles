#!/bin/sh
DOTFILES=$(cd $(dirname $0)/../.. && pwd)

[ -d "${HOME}/Library/Application Support/Btcd" ] || ln -s "${DOTFILES}/rc.d/btcd" "${HOME}/Library/Application Support/Btcd"
[ -d "${HOME}/Library/Application Support/Btcwallet" ] || ln -s "${DOTFILES}/rc.d/btcwallet" "${HOME}/Library/Application Support/Btcwallet"
