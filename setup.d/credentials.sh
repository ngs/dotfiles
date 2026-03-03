#!/bin/bash
set -eux

DBXCLI_VERSION='3.0.0'
DBXCLI_ARCH='linux-amd64'
REPO='dropbox/dbxcli'
UNAME=$(uname -s)

if [ $UNAME == 'Darwin' ]; then
  DBXCLI_ARCH='darwin-arm64'
  # https://github.com/dropbox/dbxcli/pull/187
  DBXCLI_VERSION='3.0.1'
  REPO='hfsaito/dbxcli'
fi

if ! command -v dbxcli 1>/dev/null 2>&1; then
  sudo curl -L --output /usr/local/bin/dbxcli "https://github.com/${REPO}/releases/download/v${DBXCLI_VERSION}/dbxcli-${DBXCLI_ARCH}"
  sudo chmod +x /usr/local/bin/dbxcli
fi

# dbxcli account

# [ -d ~/.ssh ] || mkdir ~/.ssh
# [ -f ~/.ssh/id_rsa ] || dbxcli get /Credentials/gpg/gpg-ngs-secret.key ~/.ssh/id_rsa
[ -f ~/.ssh/id_rsa ] && chmod 400 ~/.ssh/id_rsa
chmod 700 ~/.ssh

dbxcli get /Credentials/gpg/gpg-ngs-secret.key gpg-ngs-secret.key
cat gpg-ngs-secret.key | gpg --import || true
rm gpg-ngs-secret.key

([ -f /usr/bin/pinentry ] && [ ! -f /usr/local/bin/pinentry ] && sudo ln -s /usr/bin/pinentry /usr/local/bin/pinentry) || true
