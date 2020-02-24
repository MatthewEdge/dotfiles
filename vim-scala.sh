#!/bin/sh

ROOT_DIR=$(pwd)
brew install scala sbt

# coc Intellisense
brew install node
cd ~/.vim/pack/dist/start
curl --fail -L https://github.com/neoclide/coc.nvim/archive/release.tar.gz | tar xzfv -
cd $ROOT_DIR

# Vim Scala settings
mkdir -p ~/.vim/ftplugin
cp ./scala.vim ~/.vim/ftplugin/scala.vim

vim +CocInstall coc-metals +qall!
