#!/bin/sh

# Configure Manjaro ArchLinux w/ i3 WM

waitForIt() {
  echo "Press any key to continue..."
  read HelloIT
}

sudo pacman -Syu

# Autostart NetworkManager
sudo systemctl enable NetworkManager

# Enable AUR through yay
sudo pacman -S yay

# Copy trackpad conf
cp -f ./archlinux/etc/X11/xorg.conf.d/*.conf /etc/X11/xorg.conf.d/

# zsh insurance
sudo pacman -S zsh
yay -S oh-my-zsh-git
sudo mv /usr/share/oh-my-zsh $HOME/oh-my-zsh
sudo chown -R $(whoami):$(whoami) $HOME/oh-my-zsh

# Ensure working dir
cp -f ./.zshrc $HOME/.zshrc
cp -f ./.vimrc $HOME/.vimrc

# Add arch-specific aliases to zshrc
cat <<EOT >> $HOME/.zshrc
screenshot() {
  RES=$(xdpyinfo | grep 'dimensions:' | awk -F " " '{print $2}')
  DT=$(date +'%m-%d-%YT%H-%M-%S')
  ffmpeg -f x11grab -video_size $RES -i $DISPLAY -vframes 1 screenshot-$DT.png
}

# Image Viewing
alias open="viewnior"
EOT

# Firefox
sudo pacman -S firefox

# Git
sudo pacman -S git
sh ../git.sh

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

## Golang
sudo pacman -S go

## Docker
sudo pacman -S docker
sudo groupadd docker
sudo usermod -aG docker $(whoami)
# newgrp docker

# Misc. utilities

## Radeon Drivers
sudo pacman -S mesa libva-mesa-driver vulkan-radeon

# Audo fix
install_pulse

# Zoom
echo "Zoom Client time. Download the .tar.xz to ~/Downloads"
echo "open https://zoom.us/download?os=linux"
echo "When done - click enter..."
waitForIt()
sudo pacman -U $HOME/Downloads/zoom_x86_64.pkg.tar.xz

# Configuring default microphone
echo "Grab microphone device id:"
sudo pacmd list-sources | grep -e device.string -e 'name:'
echo "Now paste this at the bottom of /etc/pulse/default.pa:"
echo "set-default-source DEVICE-ID-HERE"
waitForIt()

# Screen capture
sudo pacman -S ffmpeg

# Source zshrc as a last step
source $HOME/.zshrc

echo "Done!"
echo "Probably a good idea to restart now!"
