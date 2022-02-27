#!/bin/sh
sudo pacman -Syu

# Git
sudo pacman -S git openssh
sh $DOTFILES_DIR/git.sh

# Terminal, clipboard sharing with vim, and font of choice
sudo pacman -S rxvt-unicode xsel xclip ttf-fira-code

# ZSH
sudo pacman -S zsh zsh-completions zsh-syntax-highlighting zsh-history-substring-search fzf ripgrep
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

## For CoC
sudo pacman -S nodejs yarn
vim +PlugInstall +qall

# For Go just download from site. Much easier

## Docker
sudo pacman -S docker
sudo groupadd docker
sudo usermod -aG docker $(whoami)
