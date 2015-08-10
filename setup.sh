#!/bin/bash

set -e

export HOMEBREW_CASK_OPTS="--appdir=/Applications"
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
NORMAL=$(tput sgr0)

msg_ok() {
  echo "${GREEN}✓ ${1}${NORMAL}"
}

msg_fail() {
  echo "${RED}✗ ${1}${NORMAL}"
}

command -v brew >/dev/null 2>&1 || {
  msg_ok "installing brew"
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
}

msg_ok "brew update"  && brew update  >/dev/null
msg_ok "brew upgrade" && brew upgrade >/dev/null

brew list brew-cask >/dev/null 2>&1 || {
  msg_ok "installing cask"
  brew tap caskroom/homebrew-cask >/dev/null
  brew install brew-cask >/dev/null
}

command -v VirtualBox >/dev/null 2>&1 || {
  msg_ok "installing virtualbox"
  brew cask install --force virtualbox >/dev/null
}

command -v vagrant >/dev/null 2>&1 || {
  msg_ok "installing vagrant"
  brew cask install --force vagrant >/dev/null
}

command -v docker >/dev/null 2>&1 || {
  msg_ok "installing docker"
  brew install docker >/dev/null
}

command -v docker-compose >/dev/null 2>&1 || {
  msg_ok "installing docker-compose"
  brew install docker-compose >/dev/null
}
