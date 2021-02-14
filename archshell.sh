#!/bin/sh
waitForIt() {
  echo "Press any key to continue..."
  read HelloIT
}

sudo pacman -Syu
sudo pacman -S neovim

# Ensure dotfiles config
export CONFIG_DIR=$CONFIG_DIR
mkdir -p $CONFIG_DIR

# Install and autostart NetworkManager
sudo pacman -S NetworkManager
sudo systemctl enable NetworkManager

# Git
sudo pacman -S git openssh
sh ../git.sh

# Enable AUR through yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -s
ls | grep yay*.zst | xargs sudo pacman -U

# Xorg
sudo pacman -S xorg xorg-xinit
mkdir -p $CONFIG_DIR/X11
rm -rf $CONFIG_DIR/X11
ln -s ./.config/X11 $CONFIG_DIR

# i3
sudo pacman -S i3wm i3status dmenu

# Terminal
sudo pacman -S \
	rxvt-unicode \
	xsel \ # for clipboard sharing
	ttf-fira-code # font of choice

# zsh insurance
sudo pacman -S zsh
yay -S oh-my-zsh-git
sudo mv /usr/share/oh-my-zsh $HOME/oh-my-zsh
sudo chown -R $(whoami):$(whoami) $HOME/oh-my-zsh

# Ensure working dir
ln -s ./.zshrc $HOME/.zshrc

ln -S ./.config/nvim/init.vim $CONFIG_DIR/nvim/init.vim

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
