#!/bin/sh
set -eux

DOTFILES=$(cd $(dirname $0)/.. && pwd)

cd $DOTFILES
git submodule update --init --recursive
gem list -i bundler || sudo gem install bundler
bundle install --path=vendor
