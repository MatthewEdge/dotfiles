export EDITOR="nvim"
export VISUAL=$EDITOR

export DOTFILES_DIR=$HOME/dotfiles
export CONFIG_DIR=$HOME/.config

# ZSH
export ZDOTDIR=$CONFIG_DIR/zsh
export HISTFILE=$ZDOTDIR/.zhistory
export HISTSIZE=10000
export SAVEHIST=10000

# FZF / RG
export FZF_DEFAULT_COMMAND="rg --files --hidden --glob '!.git'"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
