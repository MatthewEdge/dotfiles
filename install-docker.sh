#!/bin/sh
set -ex

sudo $INSTALL docker
sudo usermod -aG docker $USER
echo "Make sure to start the docker daemon with: systemctl start docker"
