#!/bin/sh
# Symlink config folders to ~/.config for a better dev experience

# Sway WM
rm -rf ~/.config/sway
ln -s $(pwd)/swaywm $HOME/.config/sway
rm -rf $HOME/.config/sway/etc

# NVIM
rm -rf $HOME/.config/nvim
ln -s $(pwd)/nvim $HOME/.config/nvim

# Foot term
mkdir -p $HOME/.config/foot
rm -f $HOME/.config/foot/foot.ini
ln -s $(pwd)/foot.ini $HOME/.config/foot/foot.ini
