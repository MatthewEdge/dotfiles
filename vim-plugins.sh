#!/bin/sh

# Usage: githubInstall user/repo
githubInstall() {
  REPO=$1
  NAME=$(echo $REPO | sed 's/\(.*\)\/\(.*\)/\2/g')

  echo "Installing $REPO to ~/.vim/pack/dist/start/$NAME"

  git clone https://github.com/$REPO.git ~/.vim/pack/dist/start/$NAME
}

# Installs my preferred Vim plugins using vim8+
githubInstall fatih/vim-go
githubInstall vim-airline/vim-airline
githubInstall tpope/vim-fugitive
githubInstall christoomey/vim-tmux-navigator
githubInstall frazrepo/vim-rainbow
githubInstall preservim/nerdcommenter
