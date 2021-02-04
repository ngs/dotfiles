#!/bin/bash
set -eux

if command -v apt-get &> /dev/null; then
  sudo apt-get update -y
  sudo apt-get install -y python3-dev tmux build-essential git vim zsh
fi

