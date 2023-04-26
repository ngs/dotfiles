#!/bin/sh

set -eux

type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
  && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \

sudo apt-get -u update
sudo apt-get -y install \
  build-essential \
  libssl-dev \
  libc6 \
  cmake \
  python3.8-dev \
  vim \
  zsh \
  pinentry-curses \
  direnv \
  jq \
  libyaml-dev \
  mysql-server \
  mysql-client \
  postgresql-all \
  gh
[ -f /usr/local/bin/pinentry ] || sudo ln -s /usr/bin/pinentry /usr/local/bin/pinentry

