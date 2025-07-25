#!/bin/bash

set -ex

ORIG=$(pwd)

# Dev Dependencies and tooling that, sadly, change between distros
if [ "$PACKMGR" == "pacman" ]; then
    sudo pacman -Syu base-devel cmake unzip ninja curl xclip
elif [ "$PACKMGR" == "apt" ]; then
    sudo apt install ninja-build gettext libtool-bin cmake g++ pkg-config unzip curl xclip wl-clipboard
else
    echo "Unknown package manager: $PACKMGR"
    exit 1
fi

if [ -d "$HOME/neovim" ]; then
    cd $HOME/neovim
    git pull
else
    git clone https://github.com/neovim/neovim.git $HOME/neovim
fi
cd $HOME/neovim

# Current: release 0.11
git checkout release-0.11

rm -rf build/  # clear the CMake cache
make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$HOME/neovim" CMAKE_BUILD_TYPE=Release
make install

cd $ORIG
