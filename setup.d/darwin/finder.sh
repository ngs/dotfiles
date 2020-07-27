#!/bin/sh

##
## Setup Finder
##
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder NewWindowTarget -string "PfHm" && \
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}"


