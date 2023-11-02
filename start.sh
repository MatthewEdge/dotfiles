#!/bin/sh

set -ex

# Attempts to automate many of the setup steps necessary for a fresh install. Also tries to manage
# the cross-distro changes so I can edit less when switching between distros.

# Pre-conf sudo 
sudo -v

PACKMGR=""
INSTALL=""
REMOVE=""

if [ -x "$(command -v apt)" ]; then
    echo "apt environment"
    PACKMGR="apt"
    INSTALL="apt install -y"
    REMOVE="apt remove -y"
elif [ -x "$(command -v pacman)" ]; then
    echo "pacman environment"
    PACKMGR="pacman"
    INSTALL="pacman -Sy --noconfirm"
    REMOVE="pacman -R"
else
    echo "Unknown package manager"
    exit 1
fi

# Base dependencies
sudo $INSTALL fzf ripgrep git curl unzip

( export PACKMGR=$PACKMGR; export INSTALL=$INSTALL; export REMOVE=$REMOVE; \
    # Git / SSH base setup
    ./git.sh && \
    ./ssh.sh && \

    # Neovim setup
    ./install-nvim.sh \
)

# Golang
echo "Install Go from the main site. Waiting..."
read x

if [ "$PACKMGR" == "pacman" ]; then
    sudo $INSTALL protobuf
elif ["$PACKMGR" == "apt" ]; then
    sudo $INSTALL protobuf-compiler
fi
# go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
#go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
#go install golang.org/x/tools/gopls@latest
#go install golang.org/x/tools/cmd/goimports@latest

# AWS CLI
# curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscli.zip"
# unzip awscli.zip
# sudo ./aws/install
# rm -rf ./aws
# rm -f awscli.zip

# Lastly - shell customizations
cp ./.zshrc $HOME/.zshrc

if [ "$PACKMGR" == "pacman" ]; then
    echo 'alias pacman="sudo pacman"' >> $HOME/.zshrc
    echo 'alias update="sudo pacman -Syu"' >> $HOME/.zshrc
elif [ "$PACKMGR" == "apt" ]; then
    echo 'alias apt="sudo apt"' >> $HOME/.zshrc
    echo 'alias update="sudo apt update -y && sudo apt upgrade"' >> $HOME/.zshrc
fi

./symlink-config.sh
# TODO - foot install
echo "Restart shell for changes to take effect"
