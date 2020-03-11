#!/bin/sh
ROOT_DIR=$(pwd)
brew install node

# Coc extensions
vim +CocInstall coc-tsserver coc-json coc-prettier +qall!
