#!/bin/bash
set -eux

sudo apt-get update -y
sudo apt-get install -y \
  apt-transport-https \
  build-essential \
  cmake \
  curl \
  direnv \
  exfat-fuse \
  git \
  moc \
  moc-ffmpeg-plugin \
  ntfs-3g \
  python3-dev \
  tmux \
  vim \
  zsh

which rclone || curl https://rclone.org/install.sh | sudo bash
systemctl is-active raspotify || curl -sL https://dtcooper.github.io/raspotify/install.sh | sh
