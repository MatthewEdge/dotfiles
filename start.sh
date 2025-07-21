#!/bin/sh

set -ex

# Attempts to automate many of the setup steps necessary for a fresh install. Also tries to manage
# the cross-distro changes so I can edit less when switching between distros.

# Pre-conf sudo 
sudo -v

# Current: deb based
PACKMGR="apt"
INSTALL="$PACKMGR install -y"
REMOVE="$PACKMGR remove -y"

# Base dependencies
sudo $INSTALL \
    fzf ripgrep \
    git \
    curl \
    unzip \
    exfalse # media meta editing

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

# AWS CLI
# curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscli.zip"
# unzip awscli.zip
# sudo ./aws/install
# rm -rf ./aws
# rm -f awscli.zip

# Lastly - shell customizations
./symlink-config.sh

# Nowadays Experiment: let it all be Bash
echo 'source $HOME/.zshrc' >> $HOME/.bashrc

echo "Restart shell for changes to take effect"
