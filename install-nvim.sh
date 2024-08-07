#!/bin/bash

set -ex

ORIG=$(pwd)

# Dev Dependencies and tooling that, sadly, change between distros
# TODO Wayland-only environments still require wl-clipboard? Never got that working
if [ "$PACKMGR" == "pacman" ]; then
    sudo $INSTALL base-devel cmake unzip ninja curl xclip
elif [ "$PACKMGR" == "apt" ]; then
    sudo $INSTALL ninja-build gettext libtool-bin cmake g++ pkg-config unzip curl xclip
elif [ "$PACKMGR" == "brew" ]; then
    # Building from source _sucks_ on Mac right now so just brew install and yeet
    brew install neovim
    exit 0
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
rm -rf build/  # clear the CMake cache
make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$HOME/neovim" CMAKE_BUILD_TYPE=Release
make install

cd $ORIG
