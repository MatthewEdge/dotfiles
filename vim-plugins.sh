#!/bin/sh

# Usage: githubInstall user/repo
githubInstall() {
  REPO=$1
  NAME=$(echo $REPO | sed 's/\(.*\)\/\(.*\)/\2/g')


  if [ -d "$HOME/.vim/pack/dist/start/$NAME" ]; then
    echo "$REPO already exists. Updating..."
    local DIR=$(pwd)
    cd ~/.vim/pack/dist/start/$NAME
    git pull origin master
    cd $DIR
    return
  fi

  echo "Installing $REPO to ~/.vim/pack/dist/start/$NAME"
  git clone https://github.com/$REPO.git ~/.vim/pack/dist/start/$NAME
}

# Installs my preferred Vim plugins using vim8+
githubInstall fatih/vim-go
githubInstall vim-airline/vim-airline
githubInstall tpope/vim-fugitive
githubInstall christoomey/vim-tmux-navigator
githubInstall jaredgorski/SpaceCamp
githubInstall preservim/nerdcommenter
githubInstall MaxMEllon/vim-jsx-pretty
