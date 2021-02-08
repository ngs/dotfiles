#!/bin/bash
set -eux

sudo apt-get update -y
sudo apt-get install -y \
  python3-dev \
  tmux \
  build-essential \
  git \
  vim \
  zsh \
  moc \
  moc-ffmpeg-plugin \
  curl \
  apt-transport-https \
  direnv \
  exfat-fuse \
  ntfs-3g

curl https://rclone.org/install.sh | sudo bash
curl -sL https://dtcooper.github.io/raspotify/install.sh | sh
