#!/bin/sh
ROOT_DIR=$(pwd)
brew install scala sbt

# coc Intellisense
vim +CocInstall coc-metals +qall!
