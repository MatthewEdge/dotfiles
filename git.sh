#!/bin/sh

# Git config
git config --global user.name "Matthew Edge"
git config --global user.email "medge@medgelabs.io"
git config --global core.pager 'diff-so-fancy | less --tabs=4 -RFX'
git config --global init.defaultBranch main
git config --global pull.rebase false

ln -s ./.config/git/.gitignore_global $HOME/.gitignore_global
git config --global core.excludesfile $HOME/.gitignore_global
