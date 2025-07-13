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
elif [ -x "$(command -v brew)" ]; then
    PACKMGR="brew"
    INSTALL="brew install"
    REMOVE="brew uninstall"
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
echo "Install Go from the main site."
echo "Go expected in /usr/local/bin/go as site describes."
read x
export PATH=$PATH:/usr/local/go/bin

# Note: this may fail on some systems for...calendar dependencies. wat
# update deps should resolve this issue
if [ "$PACKMGR" == "pacman" ]; then
    sudo $INSTALL protobuf
elif ["$PACKMGR" == "apt" ]; then
    sudo $INSTALL protobuf-compiler
fi
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
#go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
go install github.com/go-delve/delve/cmd/dlv@latest

# TODO keep this version updated somehow?
#curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.56.2

# AWS CLI
# curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscli.zip"
# unzip awscli.zip
# sudo ./aws/install
# rm -rf ./aws
# rm -f awscli.zip

# Lastly - shell customizations
./symlink-config.sh

if [ "$PACKMGR" == "pacman" ]; then
    echo 'alias pacman="sudo pacman"' >> $HOME/.zshrc
    echo 'alias update="sudo pacman -Syu"' >> $HOME/.zshrc
elif [ "$PACKMGR" == "apt" ]; then
    echo 'alias apt="sudo apt"' >> $HOME/.zshrc
    echo 'alias update="sudo apt update -y && sudo apt upgrade"' >> $HOME/.zshrc
fi

# Nowadays Experiment: let it all be Bash
echo 'source $HOME/.zshrc' >> $HOME/.bashrc

echo "Restart shell for changes to take effect"
