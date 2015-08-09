#!/bin/bash

export HOMEBREW_CASK_OPTS="--appdir=/Applications"

brew update
brew upgrade

brew tap caskroom/homebrew-cask
brew install brew-cask

brew cask install virtualbox
