# Path to your oh-my-zsh installation.
export ZSH=$HOME/oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
ZSH_THEME="robbyrussell"

DISABLE_UPDATE_PROMPT="true"
export UPDATE_ZSH_DAYS=7

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git history-substring-search)

# User configuration
source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

export EDITOR='vim'

#############################
#  USER FUNCTION HELPERS
#############################
alias zshrc="$EDITOR ~/.zshrc && source ~/.zshrc"
alias ll="ls -alh"

# Default to Python3
alias python="/usr/local/bin/python3"
alias pip="/usr/local/bin/pip3"

# Homebrew Tricks
alias brewdeps="brew leaves | xargs brew deps --installed --for-each"

# Git
alias gg='git log --oneline --abbrev-commit --all --graph --decorate --color'

gitclean() {
    git fetch -p
    git branch -r | awk '{print $1}' | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk '{print $1}' | xargs git branch -D
}

# Streams
alias sorceryDeath="$HOME/code/stream/sorcery-sync/bin/sync -f ~/DriveSync/SorcerySync/Deaths.txt"
alias showSorceryDeaths="cat $HOME/DriveSync/SorcerySync/Deaths.txt"

## Medgelabs Stream
export TWITCH_HOME=$HOME/twitch
mkdir -p $TWITCH_HOME
alias cdstream="cd $HOME/code/stream"

# VIM
export VIM_HOME="$HOME/.vim"
alias vimrc="$EDITOR ~/.vimrc"
alias cocrc="$EDITOR ~/.vim/coc-settings.json"
alias upvim="vim +PlugUpdate +PlugClean +qall"

# Note Taking
NOTES_DIR="$HOME/notes"
mkdir -p $NOTES_DIR
alias note="vim $NOTES_DIR/$(date '+%Y-%m-%d').md"
alias catnote="cat $NOTES_DIR/$(date '+%Y-%m-%d').md"
alias delnote="rm -f $NOTES_DIR/$(date '+%Y-%m-%d').md"
alias opennotes="open $NOTES_DIR"

# Vault for Local
mkdir -p $HOME/vault
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN=$(cat $HOME/vault/token)

# Kubernetes
alias kgp="kubectl get pods"
alias kgs="kubectl get svc"

# Docker
alias dkrit="docker run --rm -it -v ${PWD}:/usr/src/app -w /usr/src/app"
alias dcs="docker-compose stop"
alias dcb="docker-compose build --parallel"
alias dcu="docker-compose up"
alias dcl="docker-compose logs -f"
alias dcd="docker-compose down"
alias dcrm="docker-compose rm -f"
alias dkrmac="docker rm -f $(docker ps -aq)"

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

# Maven Aliases
alias mci="mvn clean install"
alias mcc="mvn clean compile"
alias mct="mvn clean test"
alias mcp="mvn clean package"
alias mcv="mvn clean verify"
alias mvnGenArchetype="mvn archetype:generate -DarchetypeArtifactId=maven-archetype-archetype"

# Golang
export GOPATH=$HOME/code/go
alias gotest="go test ./..."

# Scala
export SCALA_HOME=/usr/local/opt/scala/idea
export PATH=$PATH:$SCALA_HOME/bin

# Terraform
ekstf() {
  export ACCESS_KEY=$(cat ~/.aws/credentials| grep aws_access_key_id | cut -d '=' -f2 | cut -d ' ' -f2)
  export SECRET_KEY=$(cat ~/.aws/credentials| grep aws_secret_access_key | cut -d '=' -f2 | cut -d ' ' -f2)

  docker run --rm -it -e AWS_ACCESS_KEY_ID="${ACCESS_KEY}" -e AWS_SECRET_ACCESS_KEY="${SECRET_KEY}" -v $PWD:/src -w /src hashicorp/terraform:light init
  docker run --rm -it -e AWS_ACCESS_KEY_ID="${ACCESS_KEY}" -e AWS_SECRET_ACCESS_KEY="${SECRET_KEY}" -v $PWD:/src -w /src hashicorp/terraform:light apply -auto-approve
  aws eks --region us-east-1 update-kubeconfig --name medgelabs
}

ekstfd() {
  export ACCESS_KEY=$(cat ~/.aws/credentials| grep aws_access_key_id | cut -d '=' -f2 | cut -d ' ' -f2)
  export SECRET_KEY=$(cat ~/.aws/credentials| grep aws_secret_access_key | cut -d '=' -f2 | cut -d ' ' -f2)

  docker run --rm -it -e AWS_ACCESS_KEY_ID="${ACCESS_KEY}" -e AWS_SECRET_ACCESS_KEY="${SECRET_KEY}" -v $PWD:/src -w /src hashicorp/terraform:light destroy
}

alias tf="docker run --rm -it -v $PWD:/src -w /src hashicorp/terraform:light"
alias tfd="docker run --rm -it -v $PWD:/src -w /src hashicorp/terraform:light destroy"

