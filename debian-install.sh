#!/bin/sh

set -ex

ORIG=$(pwd)

sudo apt update -y

# Git / OpenSSH
sudo apt install -y git
./ssh.sh
./git.sh

# Dev Dependencies and tooling
sudo apt install -y \
    piper \
    htop \
    fzf \
    ripgrep \
    xclip \
    # for neovim
    ninja-build gettext libtool-bin cmake g++ pkg-config unzip curl && \
sudo apt remove -y vim

if [ -d "$HOME/neovim" ]; then
    cd $HOME/neovim
    git pull
else
    git clone https://github.com/neovim/neovim.git $HOME/neovim
fi
cd $HOME/neovim
rm -rf build/  # clear the CMake cache
make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$HOME/neovim"
make install

cd $ORIG

# Golang
echo "Install Go from the main site. Waiting..."
read x
sudo apt install -y protobuf-compiler
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
#go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
#go install golang.org/x/tools/gopls@latest
#go install golang.org/x/tools/cmd/goimports@latest

# AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscli.zip"
unzip awscli.zip
sudo ./aws/install
rm -rf ./aws
rm -f awscli.zip

# Reminder: key mapping
echo "Install Gnome Tweaks and under Keyboard > Additional Layout Options > check 'Swap Left Win with Left Ctrl'"
#sudo apt install -y gnome-tweaks

# Enable minimizing apps to Dock on dock icon click
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'
