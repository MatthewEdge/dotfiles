#!/bin/sh
# Variation of the Desktop install for Ubuntu Homelab setups.

set -ex

ORIG=$(pwd)

sudo apt update -y

# Git / OpenSSH
sudo apt install -y git
./git.sh

# Dev Dependencies and tooling
sudo apt install -y \
    make \
    htop \
    fzf \
    ripgrep \
    # for neovim
    ninja-build gettext libtool-bin cmake g++ pkg-config unzip curl && \
sudo apt remove -y vim

if [ ! -d "$HOME/neovim" ]; then
    git clone https://github.com/neovim/neovim.git $HOME/neovim
else
    cd $HOME/neovim
    git pull
    cd $ORIG
fi

cd $HOME/neovim
rm -r build/ || true # clear the CMake cache
make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$HOME/neovim"
make install
# Ensure neovim config link
rm -rf ~/.config/nvim
mkdir -p ~/.config/nvim
cd $ORIG
ln -s $ORIG/nvim ~/.config/nvim

# OhMyZSH
# Custom Theme
echo "Make sure to change theme in .zshrc to 'server'"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
cp ./.zshrc $HOME/.zshrc
cp ./server.zsh-theme $HOME/.oh-my-zsh/custom/themes/server.zsh-theme

