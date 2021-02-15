#!/bin/sh
waitForIt() {
  echo "Press any key to continue..."
  read HelloIT
}

sudo pacman -Syu

# Ensure dotfiles config
export DOTFILES_DIR=$HOME/dotfiles
export CONFIG_DIR=$HOME/.config
mkdir -p $CONFIG_DIR

# Install and autostart NetworkManager
sudo pacman -S networkmanager
sudo systemctl enable NetworkManager.service

# Git
sudo pacman -S git openssh
sh $DOTFILES_DIR/git.sh

# Enable AUR through yay
if [ ! -d "$HOME/yay" ]; then
  OLD_DIR=$(pwd)
  git clone https://aur.archlinux.org/yay.git $HOME/yay
  cd $HOME/yay
  makepkg -s
  ls | grep yay*.zst | xargs sudo pacman -U
  cd $OLD_DIR
fi

# neovim
sudo pacman -S neovim
mkdir -p $CONFIG_DIR/nvim
mkdir -p $CONFIG_DIR/nvim/undo
ln -sf $DOTFILES_DIR/nvim/init.vim $CONFIG_DIR/nvim

# Xorg
sudo pacman -S xorg xorg-xinit
rm -rf $CONFIG_DIR/X11
ln -s $DOTFILES_DIR/X11 $CONFIG_DIR

# i3
sudo pacman -S i3-wm i3status dmenu
rm -rf $CONFIG_DIR/i3
ln -s $DOTFILES_DIR/i3 $CONFIG_DIR

# Terminal, clipboard sharing with vim, and font of choice
sudo pacman -S rxvt-unicode xsel xclip ttf-fira-code

# ZSH
sudo pacman -S zsh zsh-completions zsh-history-substring-search fzf ripgrep
# yay -S oh-my-zsh-git
# sudo mv /usr/share/oh-my-zsh $HOME/oh-my-zsh
# sudo chown -R $(whoami):$(whoami) $HOME/oh-my-zsh
mkdir -p $CONFIG_DIR/zsh
ln -sf $DOTFILES_DIR/zsh/.zshenv $HOME
ln -sf $DOTFILES_DIR/zsh/.zshrc $CONFIG_DIR/zsh

rm -rf $CONFIG_DIR/zsh/external
ln -sf $DOTFILES_DIR/zsh/external $CONFIG_DIR/zsh

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

sudo pacman -S htop

## Radeon Drivers
sudo pacman -S mesa libva-mesa-driver vulkan-radeon

# Audo fix
#install_pulse

# Zoom
#echo "Zoom Client time. Download the .tar.xz to ~/Downloads"
#echo "open https://zoom.us/download?os=linux"
#echo "When done - click enter..."
#waitForIt
#sudo pacman -U $HOME/Downloads/zoom_x86_64.pkg.tar.xz

# Configuring default microphone
#echo "Grab microphone device id:"
#sudo pacmd list-sources | grep -e device.string -e 'name:'
#echo "Now paste this at the bottom of /etc/pulse/default.pa:"
#echo "set-default-source DEVICE-ID-HERE"
#waitForIt()

# Screen capture
sudo pacman -S ffmpeg

#startx
