#!/bin/sh

sudo apt update -y

# Vim
sudo apt remove -y vim && sudo apt install -y vim-gtk3

# Docker
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
read -r -d '' logfile <<-EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF
sudo echo "$logfile" > /etc/docker/daemon.json

# AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscli.zip"
unzip awscli.zip
sudo ./aws/install
rm -rf ./aws
rm -f awscli.zip

# Reminder: kepmapping
echo "Install Gnome Tweaks and under Keyboard > Additional Layout Options > check 'Swap Left Win with Left Ctrl'"
