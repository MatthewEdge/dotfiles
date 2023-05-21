#!/bin/bash

set -ex

commandExists() {
    command -v "$1" &> /dev/null 
}

ORIG=$(pwd)

sudo apt install -y \
    cmake \
    pkg-config \
    libfreetype6-dev \
    libfontconfig1-dev \
    libxcb-xfixes0-dev \
    libxkbcommon-dev
    # python3

if [ ! $(commandExists "rustup") ]; then
    # Note: .zshrc includes .cargo/bin in PATH, otherwise rustup commands below won't work on a new system
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi

if [ ! -d "$HOME/alacritty" ]; then
    git clone https://github.com/alacritty/alacritty.git $HOME/alacritty
else
    cd $HOME/alacritty
    git pull
    cd $ORIG
fi

cd $HOME/alacritty

rustup override set stable
rustup update stable
cargo build --release

# Ensure terminfo
infocmp alacritty
sudo tic -xe alacritty,alacritty-direct extra/alacritty.info

# System entry
sudo cp target/release/alacritty /usr/local/bin # or anywhere else in $PATH
sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
sudo desktop-file-install extra/linux/Alacritty.desktop
sudo update-desktop-database

# Manpages
sudo mkdir -p /usr/local/share/man/man1
gzip -c extra/alacritty.man | sudo tee /usr/local/share/man/man1/alacritty.1.gz > /dev/null
gzip -c extra/alacritty-msg.man | sudo tee /usr/local/share/man/man1/alacritty-msg.1.gz > /dev/null

# Shell completions
cp extra/completions/_alacritty ${ZDOTDIR:-~}/.zsh_functions/_alacritty

# Currently we just have these in .zshrc from repo
# mkdir -p ${ZDOTDIR:-~}/.zsh_functions
# fpath+=${ZDOTDIR:-~}/.zsh_functions

cd $ORIG
