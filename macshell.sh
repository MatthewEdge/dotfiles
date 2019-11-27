#!/bin/sh

# Setup preferred shell environment on Mac

# XCode
xcode-select —-install

# Homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew cask install iterm2 flux spectacle
brew install jq

# ZSH
brew install zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
zsh --version
cp ./.zshrc ~/.zshrc

# Vim
brew install vim
cp ./.vimrc ~/.vimrc
./vim-plugins.sh
