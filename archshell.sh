#!/bin/sh
waitForIt() {
  echo "Press any key to continue..."
  read HelloIT
}

DOTFILES_DIR=$HOME/dotfiles

sudo pacman -Syu
sudo pacman -S neovim

# Ensure dotfiles config
export CONFIG_DIR=$HOME/.config
mkdir -p $CONFIG_DIR

# Install and autostart NetworkManager
sudo pacman -S networkmanager
sudo systemctl enable NetworkManager.service

# Git
sudo pacman -S git openssh
sh $DOTFILES_DIR/git.sh

# Enable AUR through yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -s
ls | grep yay*.zst | xargs sudo pacman -U
cd ../
rm -rf ./yay

# Xorg
sudo pacman -S xorg xorg-xinit
mkdir -p $CONFIG_DIR/X11
ln -sf $DOTFILES_DIR/X11 $CONFIG_DIR

# i3
sudo pacman -S i3-wm i3status dmenu
mkdir -p $CONFIG_DIR/i3
ln -sf $DOTFILES_DIR/i3 $CONFIG_DIR

# Terminal, clipboard sharing with vim, and font of choice
sudo pacman -S rxvt-unicode xsel xclip ttf-fira-code

# zsh insurance
sudo pacman -S zsh
yay -S oh-my-zsh-git

if [ ! -d "$HOME/oh-my-zsh" ]; then
  sudo mv /usr/share/oh-my-zsh $HOME/oh-my-zsh
  sudo chown -R $(whoami):$(whoami) $HOME/oh-my-zsh
fi

# Ensure working dir
ln -sf ./.zshrc $HOME/.zshrc

mkdir -p $CONFIG_DIR/nvim
mkdir -p $CONFIG_DIR/nvim/undo
ln -sf $DOTFILES_DIR/nvim/init.vim $CONFIG_DIR/nvim

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

## For CoC
sudo pacman -S nodejs yarn
vim +PlugInstall +qall

## Golang
sudo pacman -S go

## Docker
sudo pacman -S docker
sudo groupadd docker
sudo usermod -aG docker $(whoami)

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

echo "Done! Don't forget to source $HOME/.zshrc"
#startx
