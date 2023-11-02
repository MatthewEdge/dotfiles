#!/bin/sh

# Debian-specific config

set -ex

ORIG=$(pwd)

sudo apt update -y

# Dev Dependencies and tooling
sudo apt install -y \
    piper \
    htop \
    xclip 

cd $ORIG

# Reminder: key mapping
echo "Install Gnome Tweaks and under Keyboard > Additional Layout Options > check 'Swap Left Win with Left Ctrl'"
#sudo apt install -y gnome-tweaks

# Enable minimizing apps to Dock on dock icon click
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'
