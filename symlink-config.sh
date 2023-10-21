#!/bin/sh
# Symlink config folders to ~/.config for a better dev experience

ln -s $(pwd)/nvim $HOME/.config/nvim
ln -s $(pwd)/alacritty $HOME/.config/alacritty
