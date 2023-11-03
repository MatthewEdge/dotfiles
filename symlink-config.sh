#!/bin/sh
# Symlink config folders to ~/.config for a better dev experience

# ZSH config
rm -f $HOME/.zshrc
rm -f $HOME/.zshenv # since SwayWM Arch pre-populates this and it screws up this setup
ln -s $(pwd)/.zshrc $HOME/.zshrc

# Sway WM
rm -rf ~/.config/sway
ln -s $(pwd)/swaywm $HOME/.config/sway

# NVIM
rm -rf $HOME/.config/nvim
ln -s $(pwd)/nvim $HOME/.config/nvim

# Foot term
mkdir -p $HOME/.config/foot
rm -f $HOME/.config/foot/foot.ini
ln -s $(pwd)/foot.ini $HOME/.config/foot/foot.ini
