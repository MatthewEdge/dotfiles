#!/bin/sh
# Symlink config folders to ~/.config for a better dev experience

# Alacritty
rm -rf ~/.config/alacritty
ln -s $(pwd)/alacritty $HOME/.config/alacritty

# Bash config
rm -f $HOME/.bashrc
ln -s $(pwd)/.bashrc $HOME/.bashrc

# TMUX
rm -f $HOME/.tmux.conf
ln -s $(pwd)/.tmux.conf $HOME/.tmux.conf

# NVIM
rm -rf $HOME/.config/nvim
ln -s $(pwd)/nvim $HOME/.config/nvim

# Hyperland
rm -rf $HOME/.config/hypr
ln -s $(pwd)/hypr $HOME/.config/hypr
rm -rf $HOME/.config/waybar
ln -s $(pwd)/waybar $HOME/.config/waybar

# Input Remapper for Linux
# rm -rf $HOME/.config/input-remapper-2/presets
# ln -s $(pwd)/input-remapper/presets $HOME/.config/input-remapper-2/presets
