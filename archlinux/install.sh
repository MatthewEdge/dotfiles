#!/bin/sh
# Install files to required places for Arch

# i3
cp ./i3/config $HOME/.i3/config
cp ./i3/i3status/config $HOME/.config/i3status/config

# uxvrt
cp ./.Xresources $HOME/.Xresources

# Touchpad
cp ./etc/X11/xorg.conf.d/30-touchpad.conf /etc/X11/xorg.conf.d/30-touchpad.conf
