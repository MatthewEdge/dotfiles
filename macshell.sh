#!/bin/sh

# Setup preferred shell environment on Mac

# Homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew tap AdoptOpenJDK/openjdk

# Commonly used casks
brew cask install iterm2 flux spectacle
brew install jq

# ZSH
brew install zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
zsh --version
cp ./.zshrc ~/.zshrc

# Vim / tmux
brew install vim tmux
cp ./.vimrc ~/.vimrc
./vim-plugins.sh

# Notes Repo
git clone git@github.com:MatthewEdge/notes.git ~/notes

# Homebrew-managed Java install
brew cask install adoptopenjdk11
java -version

