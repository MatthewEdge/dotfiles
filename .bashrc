# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

function customp {
    GREEN="\[$(tput setaf 2)\]"
    WHITE="\[$(tput setaf 7)\]"
    local BRANCH=$(git branch --show-current 2>/dev/null)
    local SUFFIX=""
    if [ ! -z "$BRANCH" ]; then
        SUFFIX="($BRANCH) "
    fi
    PS1="$GREEN\W$WHITE $SUFFIX"
}

PROMPT_COMMAND=customp

# User specific environment and startup programs
export LANG=en_US.UTF-8

export PATH="$HOME/neovim/bin:$PATH"
export EDITOR='nvim'

#############################
#  USER FUNCTION HELPERS
#############################
alias rc="$EDITOR $HOME/.bashrc && source $HOME/.bashrc"

alias ..="cd ../"
alias ...="cd ../../"

alias md5sum='md5 -r'
alias dotfiles='cd $HOME/code/dotfiles'

# ls
alias ls="ls --color=auto"
alias ll="ls -lahGtr"

# VIM
# Old alias rewrites to save my tired brain
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
vimrc() {
    # Allows file browsing to be the nvim config folder vs. wherever you call vimrc from
    OLD_DIR=$(pwd)
    cd $HOME/.config/nvim
    $EDITOR init.lua
    cd $OLD_DIR
}

forEachDir() {
    ORIG=$(pwd)
    for d in */ ; do
        [ -L "${d%/}" ] && continue
        echo "cd $d"
        cd $d
        eval $@
        cd $ORIG
    done
}

# Code folder
CODE_DIR=$HOME/code
mkdir -p $CODE_DIR

# Git

## Clone my repos
medgeclone() {
  REPO=$1

  if [ -z "$REPO" ]; then
    echo "usage: $0 REPO_NAME (without .git)"
    exit 1
  fi

  git clone git@github.com:MatthewEdge/$REPO.git
}

alias cdlab="cd $HOME/code/labs"
labclone() {
    git clone git@github.com:medgelabs/$@
}

alias gg='git log --oneline --abbrev-commit --all --graph --decorate --color'
alias gs='git status'
alias ga='git add'
alias gb='git branch'
alias gco='git checkout'
alias gc='git commit'
alias gcm='git commit -m'
alias gd='git diff'
alias gds='git diff --staged'
alias gp='git fetch --prune && git pull'
alias grbm='git fetch origin && git rebase origin/main'
alias glog='git log -n'
gpocb() {
  git push origin $(git branch --show-current)
}
gsetb() {
    BRANCH=$(git branch --show-current)
    git branch --set-upstream-to=origin/$BRANCH $BRANCH
}

# Docker
alias docker='podman'

alias dkrit="docker run --rm -it -v ${PWD}:/usr/src/app -w /usr/src/app"
alias dcs="docker compose stop"
alias dcb="docker compose build --parallel"
alias dcu="docker compose up"
alias dcl="docker compose logs -f"
alias dcd="docker compose down"
alias dcrm="docker compose rm -f"
dkrmac() {
  docker rm -f $(docker ps -aq)
}

# Rebuild given containers (or all in YAML if no args passed)
dcre() {
  CONTAINERS=$1

  docker compose stop ${CONTAINERS} && \
  docker compose kill ${CONTAINERS} && \
  docker compose rm -f ${CONTAINERS} && \
  docker compose build --parallel --no-cache ${CONTAINERS} && \
  docker compose up -d ${CONTAINERS}
}

# REST Helpers
alias postJson="curl -H \"Content-Type: application/json\""

# NodeJS
alias npmls="npm ls -g --parsable true --depth 1"

nbin() {
  ./node_modules/.bin/"$@"
}

# Golang
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/code/go
export PATH=$PATH:$GOPATH/bin
alias gotest="go test ./..."

profile() {
    if [ -z "$1" ]; then
        echo "Usage: $0 TARGET"
        exit 1
    fi
    curl http://$1/debug/pprof/cpu -o cpu.profile
}

pprof() {
    SOURCE=$1
    if [ -z "$SOURCE" ]; then
        echo "Usage: $0 SOURCE_PPROF"
        exit 1
    fi

    go tool pprof -trim_path=/go/src -source_path=. $SOURCE
}

diffpprof() {
    BASE=$1
    LATEST=$2
    if [ -z "$BASE" ] || [ -z "$LATEST" ]; then
        echo "Usage: $0 BASE_PROFILE LATEST_PROFILE"
        exit 1
    fi

    go tool pprof -trim_path=/go/src -source_path=. -diff_base=$BASE $LATEST
}

# Terraform
awstf-dry() {
  export ACCESS_KEY=$(cat ~/.aws/credentials| grep aws_access_key_id | cut -d '=' -f2 | cut -d ' ' -f2)
  export SECRET_KEY=$(cat ~/.aws/credentials| grep aws_secret_access_key | cut -d '=' -f2 | cut -d ' ' -f2)

  docker run --rm -it -e AWS_ACCESS_KEY_ID="${ACCESS_KEY}" -e AWS_SECRET_ACCESS_KEY="${SECRET_KEY}" -v $PWD:/src -w /src hashicorp/terraform:light init
  docker run --rm -it -e AWS_ACCESS_KEY_ID="${ACCESS_KEY}" -e AWS_SECRET_ACCESS_KEY="${SECRET_KEY}" -v $PWD:/src -w /src hashicorp/terraform:light fmt
  docker run --rm -it -e AWS_ACCESS_KEY_ID="${ACCESS_KEY}" -e AWS_SECRET_ACCESS_KEY="${SECRET_KEY}" -v $PWD:/src -w /src hashicorp/terraform:light plan
  # docker run --rm -it -e AWS_ACCESS_KEY_ID="${ACCESS_KEY}" -e AWS_SECRET_ACCESS_KEY="${SECRET_KEY}" -v $PWD:/src -w /src hashicorp/terraform:light apply -auto-approve
}

awstf-apply() {
  export ACCESS_KEY=$(cat ~/.aws/credentials| grep aws_access_key_id | cut -d '=' -f2 | cut -d ' ' -f2)
  export SECRET_KEY=$(cat ~/.aws/credentials| grep aws_secret_access_key | cut -d '=' -f2 | cut -d ' ' -f2)

  docker run --rm -it -e AWS_ACCESS_KEY_ID="${ACCESS_KEY}" -e AWS_SECRET_ACCESS_KEY="${SECRET_KEY}" -v $PWD:/src -w /src hashicorp/terraform:light init
  docker run --rm -it -e AWS_ACCESS_KEY_ID="${ACCESS_KEY}" -e AWS_SECRET_ACCESS_KEY="${SECRET_KEY}" -v $PWD:/src -w /src hashicorp/terraform:light apply -auto-approve
}

awstf-destroy() {
  export ACCESS_KEY=$(cat ~/.aws/credentials| grep aws_access_key_id | cut -d '=' -f2 | cut -d ' ' -f2)
  export SECRET_KEY=$(cat ~/.aws/credentials| grep aws_secret_access_key | cut -d '=' -f2 | cut -d ' ' -f2)

  docker run --rm -it -e AWS_ACCESS_KEY_ID="${ACCESS_KEY}" -e AWS_SECRET_ACCESS_KEY="${SECRET_KEY}" -v $PWD:/src -w /src hashicorp/terraform:light init
  docker run --rm -it -e AWS_ACCESS_KEY_ID="${ACCESS_KEY}" -e AWS_SECRET_ACCESS_KEY="${SECRET_KEY}" -v $PWD:/src -w /src hashicorp/terraform:light destroy
}

alias tf="docker run --rm -it -v $PWD:/src -w /src hashicorp/terraform:light"
alias tfd="docker run --rm -it -v $PWD:/src -w /src hashicorp/terraform:light destroy"

# Python
# alias ansible-playbook="/Users/medge/Library/Python/3.9/bin/ansible-playbook"

# export PYENV_ROOT="$HOME/.pyenv"
# [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init -)"
# eval "$(pyenv virtualenv-init -)"

# If amdgpu is not installed: https://amdgpu-install.readthedocs.io/en/latest/install-installing.html
#alias amdupdate="amdgpu-install --usecase=graphics,opencl --vulkan=amdvlk --accept-eula"

# Rust setup for HTMX
#source "$HOME/.cargo/env"

# Odin
export PATH=$PATH:$HOME/odin-2025-07

# Zig
export PATH=$PATH:$HOME/zig-0.15.1

# Tiled Editor
alias tiled="$HOME/Tiled-1.11.2.AppImage"
