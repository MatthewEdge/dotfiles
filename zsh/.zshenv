export EDITOR="vim"
export VISUAL=$EDITOR

export DOTFILES_DIR=$HOME/code/dotfiles
export CONFIG_DIR=$HOME/.config

export XDG_CONFIG_HOME=$CONFIG_DIR

# ZSH
export ZDOTDIR=$DOTFILES_DIR/zsh
export HISTFILE=$ZDOTDIR/.zhistory
export HISTSIZE=10000
export SAVEHIST=10000

# FZF / RG
export FZF_BASE=/usr/local/opt/fzf
export FZF_DEFAULT_COMMAND="rg --files --hidden --glob '!.git'"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
