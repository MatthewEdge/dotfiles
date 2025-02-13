#!/bin/sh
# Symlink config folders to ~/.config for a better dev experience

# Alacritty
rm -rf $HOME/.config/alacritty
ln -s $(pwd)/alacritty $HOME/.config/alacritty

# Ghostty
rm -rf $HOME/.config/ghostty
ln -s $(pwd)/ghostty $HOME/.config/ghostty

# ZSH config
rm -f $HOME/.zshrc
rm -f $HOME/.zshenv # since SwayWM Arch pre-populates this and it screws up this setup
ln -s $(pwd)/.zshrc $HOME/.zshrc

# TMUX
rm -f $HOME/.tmux.conf
ln -s $(pwd)/.tmux.conf $HOME/.tmux.conf

# NVIM
rm -rf $HOME/.config/nvim
ln -s $(pwd)/nvim $HOME/.config/nvim

# Input Remapper for Linux
# rm -rf $HOME/.config/input-remapper-2/presets
# ln -s $(pwd)/input-remapper/presets $HOME/.config/input-remapper-2/presets

# Sway WM
# rm -rf ~/.config/sway
# ln -s $(pwd)/swaywm $HOME/.config/sway

# Foot term
# mkdir -p $HOME/.config/foot
# rm -f $HOME/.config/foot/foot.ini
# ln -s $(pwd)/foot.ini $HOME/.config/foot/foot.ini
