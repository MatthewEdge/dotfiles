# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
ZSH_THEME="robbyrussell"

DISABLE_UPDATE_PROMPT="true"
export UPDATE_ZSH_DAYS=7

plugins=(git history-substring-search)

# User configuration
source $ZSH/oh-my-zsh.sh

export LANG=en_US.UTF-8

export PATH="$HOME/neovim/bin:$PATH"
export EDITOR='nvim'

#############################
#  USER FUNCTION HELPERS
#############################
alias zshrc="$EDITOR $HOME/.zshrc && source $HOME/.zshrc"

alias md5sum='md5 -r'
alias dotfiles='cd $HOME/code/dotfiles'

alias apt="sudo apt"

# ls
alias ls="ls --color=auto"
alias ll="ls -lahG"

alias update="brew update && brew upgrade"

alias ports="lsof -i -P | grep -i 'listen'"

# VIM
# Old alias rewrites to save my tired brain
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

alias gg='git log --oneline --abbrev-commit --all --graph --decorate --color'
alias gs='git status'
alias ga='git add'
alias gb='git branch'
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

# Note Taking, hosted by Mkdocs
# source $HOME/medgedocs/notes.sh

# Kubernetes
alias k='kubectl'
alias kgp="kubectl get pods"
alias kgpan="kubectl get pods --all-namespaces -o wide"
alias kgs="kubectl get svc"

# Docker
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

  docker-compose stop ${CONTAINERS} && \
  docker-compose kill ${CONTAINERS} && \
  docker-compose rm -f ${CONTAINERS} && \
  docker-compose build --parallel --no-cache ${CONTAINERS} && \
  docker-compose up -d ${CONTAINERS}
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

pprof() {
    if [ -z "$1" ]; then
        echo "Usage: $0 TARGET"
        exit 1
    fi
    curl http://$1/debug/pprof/cpu -o cpu.profile
}

diffpprof() {
    echo "Not Implemented"
}

## Protobuf
export PROTOPATH=$HOME/protobuf
export PATH=$PATH:$PROTOPATH/bin

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

alias cdlab="cd $HOME/code/medgelabs"
labclone() {
    git clone git@github.com:medgelabs/$@
}

# Python
# alias ansible-playbook="/Users/medge/Library/Python/3.9/bin/ansible-playbook"

# If amdgpu is not installed: https://amdgpu-install.readthedocs.io/en/latest/install-installing.html
alias amdupdate="amdgpu-install --usecase=graphics,opencl --vulkan=amdvlk --accept-eula"

# Rust setup for HTMX
source "$HOME/.cargo/env"

# Python
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
