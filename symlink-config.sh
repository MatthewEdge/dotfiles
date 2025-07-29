#!/bin/sh
# Symlink config folders to ~/.config for a better dev experience

# Ghostty
rm -rf $HOME/.config/ghostty
ln -s $(pwd)/ghostty $HOME/.config/ghostty

# Bash config
rm -f $HOME/.bashrc
ln -s $(pwd)/.bashrc $HOME/.bashrc

# TMUX
rm -f $HOME/.tmux.conf
ln -s $(pwd)/.tmux.conf $HOME/.tmux.conf

# NVIM
rm -rf $HOME/.config/nvim
ln -s $(pwd)/nvim $HOME/.config/nvim

# Input Remapper for Linux
# rm -rf $HOME/.config/input-remapper-2/presets
# ln -s $(pwd)/input-remapper/presets $HOME/.config/input-remapper-2/presets
