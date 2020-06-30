#!/bin/sh
# Setup preferred shell environment on Mac
# Run this first!

# Homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew tap AdoptOpenJDK/openjdk

# Commonly used casks
brew cask install iterm2 flux spectacle
brew install jq

# Github CLI
brew install hub

cp ./.zshrc ~/.zshrc

# Vim
brew install vim
cp ./.vimrc ~/.vimrc
vim +PlugInstall +qall!

# For coc extensions
brew install node

# Notes Repo
git clone git@github.com:MatthewEdge/notes.git ~/notes

# Homebrew-managed Java install
brew cask install adoptopenjdk11
java -version

# ZSH
brew install zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
zsh --version
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Git config
git config --global core.pager 'cat'
git config --global user.name 'Matthew Edge'
git config --global user.email 'medge@medgelabs.io'

# Scala
brew install scala sbt

# coc Intellisense
vim +CocInstall coc-metals +qall!

# JS
brew install node

# Coc extensions
vim +CocInstall coc-tsserver coc-json +qall!
