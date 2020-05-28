#!/bin/sh

DIR="$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk"

if [ -d "${DIR}" ]; then
  source "${DIR}/path.zsh.inc"
  source "${DIR}/completion.zsh.inc"
fi
