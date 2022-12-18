#!/bin/sh

set -ex

sudo apt update -y

# Git / OpenSSH
sudo apt install -y git
./ssh.sh
./git.sh

# Dev Dependencies and tooling
sudo apt install -y \
	piper \
	steam \
	htop \
	fzf \
	ripgrep \
	neovim

# Neovim
sudo apt remove -y vim

# Docker && Docker Compose
sudo apt install -y
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update -y && sudo apt install -y docker-ce
sudo usermod -aG docker $(whoami)
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
sudo mv ./ubuntu/etc/docker/daemon.json /etc/docker/daemon.json
sudo chown docker:docker /etc/docker/daemon.json

COMPOSE_VER=2.12.2
curl -L "https://github.com/docker/compose/releases/download/v$COMPOSE_VER/docker-compose-$(uname -s| tr '[:upper:]' '[:lower:]')-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
chown $(whoami): /usr/local/bin/docker-compose

# Golang
echo "Install Go from the main site. Waiting..."
read x
sudo apt install -y protobuf-compiler
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
go install golang.org/x/tools/gopls@latest
go install golang.org/x/tools/cmd/goimports@latest

# AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscli.zip"
unzip awscli.zip
sudo ./aws/install
rm -rf ./aws
rm -f awscli.zip

# Reminder: key mapping
echo "Install Gnome Tweaks and under Keyboard > Additional Layout Options > check 'Swap Left Win with Left Ctrl'"
sudo apt install -y gnome-tweaks
