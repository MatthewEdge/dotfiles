#!/bin/sh
# Setup preferred shell environment on Mac

# Override Git with latest version
brew install git
brew link --overwrite git

# ZSH
brew install zsh
#sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
#zsh --version

# Homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew tap AdoptOpenJDK/openjdk

# Commonly used casks
brew cask install iterm2 flux rectangle
brew install jq

# Github CLI
brew install hub

cp ./.zshrc ~/.zshrc
cp ./.vimrc ~/.vimrc

# Vim
brew install vim
vim +PlugInstall +qall!

# For coc extensions
brew install node

# Notes Repo
# git clone git@github.com:MatthewEdge/notes.git ~/notes

# Homebrew-managed Java install
brew cask install adoptopenjdk11
java -version

# Scala
brew install scala sbt
vim +CocInstall coc-metals +qall!

# JS
vim +CocInstall coc-tsserver coc-json +qall!

# Git config
git config --global user.name "Matthew Edge"
git config --global user.email "medge@medgelabs.io"
git config --global core.pager 'less'
git config --global init.defaultBranch main
git config --global pull.rebase false
