#!/bin/sh
set -ex

# gnome-specific config

# sudo $INSTALL \
    # piper \
    # htop \
    # xclip

# Reminder: key mapping
echo "Install Gnome Tweaks and under Keyboard > Additional Layout Options > Ctrl position > check 'Swap Left Win with Left Ctrl'"
#sudo apt install -y gnome-tweaks

# Enable minimizing apps to Dock on dock icon click
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'
