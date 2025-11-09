#!/bin/sh
pacman -Syu

pacman -S yay firefox alacritty fuzzel
yay -S niri noctalia-shell

# nvim
pacman -S fzf ripgrep clang wl-clipboard neovim
