#!/bin/sh
set -ex

sudo $INSTALL docker docker-compose
sudo usermod -aG docker $USER
echo "Make sure to start the docker daemon with: systemctl start docker"
