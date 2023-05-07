#!/bin/sh
# Variation of the Desktop install for Ubuntu Homelab setups.
# Run from $HOME

set -ex

ORIG=$(pwd)

sudo apt update -y

# Git / OpenSSH
sudo apt install -y git
./git.sh

# Dev Dependencies and tooling
sudo apt install -y \
    htop \
    fzf \
    ripgrep \
    xclip \
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
ln -s $(pwd)/nvim ~/.config/nvim

# OhMyZSH
# Custom Theme
cp ./server.zsh-theme $ZSH_CUSTOM/themes/server.zsh-theme
echo "Make sure to change theme in .zshrc to 'server'"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
cp ./.zshrc $HOME/.zshrc

