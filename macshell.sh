#!/bin/sh
# Setup preferred shell environment on Mac

# Ask for sudo early
echo "Input password for sudo-enabled commands: "
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Homebrew
if ! hash brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

sudo chown -R $(whoami) /usr/local/bin

# For removing kegs and their dependencies: brew rmtree FORMULA
brew tap beeftornado/rmtree

# Good ol' CLI tools
brew install tree

# Git
# Override Git with latest version
brew install git
brew link --overwrite git
sh git.sh

# SSH
sh ssh.sh

# ZSH
brew install zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

## Fix for oh-my-zsh folder for .zshrc
mv $HOME/.oh-my-zsh $HOME/oh-my-zsh

# Commonly used casks
brew install --cask iterm2 flux rectangle

# JSON processing on the CLI
brew install jq

# Fast search
brew install ripgrep

# Github CLI
brew install hub

cp ./zsh/.zshrc ~/.zshrc
cp ./zsh/.zshenv ~/.zshenv
cp ./.vimrc ~/.vimrc

# Vim
brew install vim node yarn fzf
vim +PlugInstall +qall!

