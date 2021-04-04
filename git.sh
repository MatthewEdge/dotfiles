#!/bin/sh

# Git config
git config --global user.name "Matthew Edge"
git config --global user.email "medge@medgelabs.io"
git config --global core.pager 'cat'
git config --global init.defaultBranch main
git config --global pull.rebase false

cp .gitignore_global $HOME/.gitignore_global
git config --global core.excludesfile $HOME/.gitignore_global
