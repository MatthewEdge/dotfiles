#!/bin/sh

# Git config
git config --global user.name "Matthew Edge"
git config --global user.email "medge@medgelabs.io"
git config --global core.pager 'less'
git config --global init.defaultBranch main
git config --global pull.rebase false

touch ~/.gitignore_global
git config --global core.excludesfile $HOME/.gitignore_global
echo ".DS_Store" >> $HOME/.gitignore_global
