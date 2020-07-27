#!/bin/sh

defaults write -g ApplePressAndHoldEnabled -bool false
defaults write -g InitialKeyRepeat -int 10
defaults write -g KeyRepeat -int 1

defaults write com.runningwithcrayons.Alfred-Preferences-3 syncfolder -string ~/Dropbox/Library/Alfred

defaults write com.apple.Terminal 'Startup Window Settings' -string 'Tomorrow Night Eighties'
