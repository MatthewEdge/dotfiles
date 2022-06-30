#!/bin/sh

sudo pacman-mirrors --fasttrack 7
sudo pacman -Syyu

# Git
sudo pacman -S git openssh
./git.sh

# Terminal, clipboard sharing with vim, and font of choice
sudo pacman -S rxvt-unicode xsel xclip ttf-fira-code

# ZSH
sudo pacman -S zsh zsh-completions zsh-syntax-highlighting zsh-history-substring-search fzf ripgrep
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

cp ./zsh/zshrc $HOME/.zshrc

## For CoC
sudo pacman -S nodejs yarn
vim +PlugInstall +qall

# For Go just download from site. Much easier
echo "Install Go from the main site"

## Docker
sudo pacman -S docker
sudo groupadd docker
sudo usermod -aG docker $(whoami)

COMPOSE_VER=2.2.3
curl -L "https://github.com/docker/compose/releases/download/v$COMPOSE_VER/docker-compose-$(uname -s| tr '[:upper:]' '[:lower:]')-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
chown $(whoami): /usr/local/bin/docker-compose

## Python
python -m pip install --upgrade pip
