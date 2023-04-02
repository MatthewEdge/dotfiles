#!/bin/sh
# Symlink nvim conf to ~/.config/nvim for a better dev experience

rm -rf ~/.config/nvim
ln -s $(pwd)/nvim ~/.config/nvim
