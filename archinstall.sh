#!/bin/sh
# Post-installation process for Manjaro to get all the usual apps and shell
# setup

sudo pacman-mirrors --geoip
sudo pacman -Syu --noconfirm

hwclock --systohc
timedatectl set-ntp true
timedatectl set-timezone "America/New_York"

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Git
sudo pacman -S --noconfirm git openssh
./git.sh

# Enable AUR through yay
if [ ! -d "$HOME/yay" ]; then
  OLD_DIR=$(pwd)
  git clone https://aur.archlinux.org/yay.git $HOME/yay
  cd $HOME/yay
  makepkg -s
  ls | grep yay*.zst | xargs sudo pacman -U
  cd $OLD_DIR
fi

# Firefox
sudo pacman -S --noconfirm firefox

# Mouse management for Logitech G600
pacman -S --noconfirm piper

# Steam
sudo pacman -S --noconfirm steam

## Radeon Drivers if we ever swap back (bloody CUDA...)
# sudo pacman -S --noconfirm mesa libva-mesa-driver vulkan-radeon

# Screen capture
sudo pacman -S --noconfirm ffmpeg

# SMB for Gnome Nautilus
sudo pacman -S --noconfirm gvfs-smb manjaro-settings-samba nautilus-share


# Shell Setup

# Python (mostly for neovim)
python -m pip install --upgrade pip

# neovim
sudo pacman -R --noconfirm vim
sudo pacman -S --noconfirm neovim xsel xclip
mkdir -p $HOME/.config/nvim
cp -R ./nvim $HOME/.config/nvim
python -m pip install --user pynvim

# Better top
sudo pacman -S --noconfirm htop

# ZSH
sudo pacman -S --noconfirm zsh fzf ripgrep
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

cp ./.zshrc $HOME/.zshrc

# Docker
sudo pacman -S docker
sudo groupadd docker
sudo usermod -aG docker $(whoami)

COMPOSE_VER=2.12.2
curl -L "https://github.com/docker/compose/releases/download/v$COMPOSE_VER/docker-compose-$(uname -s| tr '[:upper:]' '[:lower:]')-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
chown $(whoami): /usr/local/bin/docker-compose

# Golang
echo "Install Go from the main site. Waiting..."
read x
sudo pacman -S protobuf
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
go install golang.org/x/tools/gopls@latest
go install golang.org/x/tools/cmd/goimports@latest


# Games and such

# For PoE
sudo pacman -S --noconfirm lutris
yay -S awakened-poe-trade-git
