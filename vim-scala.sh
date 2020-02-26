#!/bin/sh
ROOT_DIR=$(pwd)
brew install scala sbt

# coc Intellisense
brew install node yarn

# Vim Scala settings
mkdir -p ~/.vim/ftplugin
cp ./scala.vim ~/.vim/ftplugin/scala.vim
