#!/bin/sh

brew install scala sbt

# coc Intellisense
cd ~/.vim/pack/dist/start
curl --fail -L https://github.com/neoclide/coc.nvim/archive/release.tar.gz | tar xzfv -

# Vim Scala settings
mkdir -p ~/.vim/ftplugin
cp ./scala.vim ~/.vim/ftplugin/scala.vim

vim +CocInstall coc-metals +qall!
