#!/bin/bash

set -ex

ORIG=$(pwd)
PACKMGR="apt"

# Dev Dependencies and tooling that, sadly, change between distros
if [ "$PACKMGR" == "pacman" ]; then
    sudo pacman -Syu base-devel cmake unzip ninja curl xclip
elif [ "$PACKMGR" == "apt" ]; then
    sudo apt install build-essential cmake g++ clang llvm-20 
else
    echo "Unknown package manager: $PACKMGR"
    exit 1
fi

if [ -d "$HOME/zig" ]; then
    cd $HOME/zig
    git pull -f
else
    git clone https://codeberg.org/ziglang/zig.git $HOME/zig
fi
cd $HOME/zig

# Current: release 0.15.2 as that is what is required for Ghostty
git checkout -f master # ensure we're at baseline in case an error occurred
git checkout 0.15.2

rm -rf build/  # clear the CMake cache
rm -rf .deps/  # ensure clean deps builds 
mkdir build
cd build
cmake ..
make install

cd $ORIG
