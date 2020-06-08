#!/bin/sh

# Configure Manjaro ArchLinux w/ i3 WM
# Should be run with root priviledges

pacman -Syy

# Autostart NetworkManager
systemctl enable NetworkManager

# Copy trackpad conf
cp -f ./archlinux/etc/X11/xorg.conf.d/30-touchpad.conf /etc/X11/xorg.conf.d/30-touchpad.conf
# systemctl restart lightdm

# Ensure working dir
mkdir -p $HOME/code
cp -f ./.zshrc $HOME/.zshrc
cp -f ./.vimrc $HOME/.vimrc

# Ensure packages

## Vim
pacman -S vim nodejs git
vim +PlugInstall +qall

## Scala
pacman -S jdk-openjdk scala sbt
vim +CocInstall coc-metals

# Git
pacman -S git
git config --global user.name "Matthew Edge"
git config --global user.email "mattedgeis@gmail.com"

# Misc. utilities

## Radeo Drivers
# TODO necessary?
pacman -S mesa libva-mesa-driver vulkan-radeon

install_pulse

# Zoom
echo "Zoom Client time. Download the .tar.xz to ~/Downloads"
open "https://zoom.us/download?os=linux"
pacman -U $HOME/Downloads/zoom_x86_64.pkg.tar.xz

# Configuring default microphone
echo "Grab microphone device id:"
pacmd list-sources | grep -e device.string -e 'name:'
echo "Now paste this at the bottom of /etc/pulse/default.pa:"
echo "set-default-source DEVICE-ID-HERE"

echo "Probably a good idea to restart now!"
