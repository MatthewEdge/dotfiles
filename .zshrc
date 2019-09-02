# Path to your oh-my-zsh installation.
export ZSH=/Users/medge/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="robbyrussell"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

# User configuration

export PATH="$PATH:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
source $ZSH/oh-my-zsh.sh

# export LANG=en_US.UTF-8

export EDITOR='vim'

#############################
#  USER FUNCTION HELPERS
#############################
alias zshrc="$EDITOR ~/.zshrc && source ~/.zshrc"

# VIM
alias vimrc="$EDITOR ~/.vimrc"

# Kubernetes
kgp="kubectl get pods"
kgs="kubectl get svc"

# Raspberry Pi
alias rpisshfile="touch /Volumes/boot/ssh"

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
  docker-compose build --no-cache ${CONTAINERS} && \
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
export GOPATH=/Users/medge/code/go
alias cdmygo="cd $GOPATH/src/github.com/MatthewEdge"

# Scala
export SCALA_HOME=/usr/local/opt/scala/idea
export PATH=$PATH:$SCALA_HOME/bin
