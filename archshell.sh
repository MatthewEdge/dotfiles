#!/bin/sh

# Configure Manjaro ArchLinux w/ i3 WM

sudo pacman -Syu

# Autostart NetworkManager
sudo systemctl enable NetworkManager

# Copy trackpad conf
cp -f ./archlinux/etc/X11/xorg.conf.d/*.conf /etc/X11/xorg.conf.d/

# zsh insurance
pacman -S zsh
rm -rf $HOME/.oh-my-zsh

# Ensure working dir
mkdir -p $HOME/code
cp -f ./.zshrc $HOME/.zshrc
cp -f ./.vimrc $HOME/.vimrc

# Firefox
sudo pacman -S firefox

# Git
sudo pacman -S git
git config --global user.name "Matthew Edge"
git config --global user.email "mattedgeis@gmail.com"
git config --global core.pager 'cat'

# Ensure packages

# Font preference
sudo pacman -S otf-fira-code
cp -f ./archlinux/.Xresources $HOME/.Xresources

## Vim (need node for CoC)
sudo pacman -S gvim nodejs
vim +PlugInstall +qall

## Java/Scala
sudo pacman -S jdk-openjdk scala sbt
vim +CocInstall coc-metals +qall

## JS/TS
vim +CocInstall coc-tsserver +qall

## Docker
sudo pacman -S docker
sudo groupadd docker
sudo usermod -aG docker $(whoami)
# newgrp docker

# Misc. utilities

## Radeo Drivers
sudo pacman -S mesa libva-mesa-driver vulkan-radeon

# Audo fix
install_pulse

# Zoom
echo "Zoom Client time. Download the .tar.xz to ~/Downloads"
echo "open https://zoom.us/download?os=linux"
echo "When done - click enter..."
read WaitForIt
sudo pacman -U $HOME/Downloads/zoom_x86_64.pkg.tar.xz

# Configuring default microphone
echo "Grab microphone device id:"
pacmd list-sources | grep -e device.string -e 'name:'
echo "Now paste this at the bottom of /etc/pulse/default.pa:"
echo "set-default-source DEVICE-ID-HERE"

# Screen capture
sudo pacman -S ffmpeg
echo "ffmpeg capture aliases in zshrc"

# Source zshrc as a last step
source $HOME/.zshrc

echo "Done!"
echo "Probably a good idea to restart now!"
