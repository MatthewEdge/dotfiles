#!/bin/sh
ROOT_DIR=$(pwd)
brew install node

# Vim settings
cp ./js.vim ~/.vim/autoload/js.vim

# Coc extensions
vim +CocInstall coc-tsserver coc-json coc-prettier coc-eslint +qall!
