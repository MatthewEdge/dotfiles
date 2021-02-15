#!/bin/sh
sudo pacman -Syu

# Ensure dotfiles config
export DOTFILES_DIR=$HOME/dotfiles
export CONFIG_DIR=$HOME/.config
mkdir -p $CONFIG_DIR

# Git
sudo pacman -S git openssh diff-so-fancy
sh $DOTFILES_DIR/git.sh

# neovim
sudo pacman -S neovim
mkdir -p $CONFIG_DIR/nvim
mkdir -p $CONFIG_DIR/nvim/undo
ln -sf $DOTFILES_DIR/nvim/init.vim $CONFIG_DIR/nvim

# Terminal, clipboard sharing with vim, and font of choice
sudo pacman -S rxvt-unicode xsel xclip ttf-fira-code

# ZSH
sudo pacman -S zsh zsh-completions zsh-syntax-highlighting zsh-history-substring-search fzf ripgrep
# yay -S oh-my-zsh-git
# sudo mv /usr/share/oh-my-zsh $HOME/oh-my-zsh
# sudo chown -R $(whoami):$(whoami) $HOME/oh-my-zsh
mkdir -p $CONFIG_DIR/zsh
ln -sf $DOTFILES_DIR/zsh/.zshenv $HOME
ln -sf $DOTFILES_DIR/zsh/.zshrc $CONFIG_DIR/zsh

rm -rf $CONFIG_DIR/zsh/external
ln -sf $DOTFILES_DIR/zsh/external $CONFIG_DIR/zsh

## For CoC
sudo pacman -S nodejs yarn
vim +PlugInstall +qall

## Golang
sudo pacman -S go

## Docker
sudo pacman -S docker
sudo groupadd docker
sudo usermod -aG docker $(whoami)
