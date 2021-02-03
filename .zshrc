# Path to your oh-my-zsh installation.
export ZSH=$HOME/oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
ZSH_THEME="robbyrussell"

DISABLE_UPDATE_PROMPT="true"
export UPDATE_ZSH_DAYS=7

plugins=(git history-substring-search)

# User configuration
source $ZSH/oh-my-zsh.sh

export LANG=en_US.UTF-8
export EDITOR='vim'

#############################
#  USER FUNCTION HELPERS
#############################
alias zshrc="$EDITOR ~/.zshrc && source ~/.zshrc"
alias srczsh='source ~/.zshrc'

# ls
alias ll="ls -alh"

# Code folder
CODE_DIR=$HOME/code
mkdir -p $CODE_DIR

# Homebrew Tricks
alias upbrew='brew update && brew upgrade && brew cleanup'
alias brewdeps='brew leaves | xargs brew deps --installed --for-each'

# Git

# Echos the current directory's git branch name (if any)
# Thanks marksost/dotfiles !
function git_branch_name() {
  echo -e "$(git symbolic-ref --quiet --short HEAD 2> /dev/null || \
    git rev-parse --short HEAD 2> /dev/null || \
    echo '(unknown)')"
}

alias gg='git log --oneline --abbrev-commit --all --graph --decorate --color'
alias gs='git status'
alias ga='git add'
alias gall='git add --all'
alias gc='git commit -m '
alias gd='git diff'
alias gds='git diff --staged'
alias gp='git fetch --prune && git pull'
alias grbm='git fetch origin && git rebase origin/main'
alias gpocb="git push origin $(git_branch_name)"

gitclean() {
    git fetch -p
    git branch -r | awk '{print $1}' | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk '{print $1}' | xargs git branch -D
}

# MacOS specific helpers

# Empty the Trash on all mounted volumes and the main HDD.
# Also, clear Apple’s System Logs to improve shell startup speed.
# Finally, clear download history from quarantine. https://mths.be/bum
alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl; sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* 'delete from LSQuarantineEvent'"

# Show/hide hidden files in Finder
alias showfiles="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hidefiles="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

# Medgelabs Stream
export TWITCH_HOME=$HOME/twitch
mkdir -p $TWITCH_HOME
alias cdstream="cd $CODE_DIR/stream"
alias cdbot="cd $CODE_DIR/stream/medgebot"

startStream() {
  OLD_DIR=$(pwd)
  cd $CODE_DIR/stream/stream-config
  ./startStream.sh
  cd $OLD_DIR
}

# VIM
export VIM_HOME="$HOME/.vim"
alias vimrc="$EDITOR ~/.vimrc"
alias cocrc="$EDITOR ~/.vim/coc-settings.json"
alias upvim="vim +PlugUpdate +PlugClean +qall!"

# Note Taking, hosted by Mkdocs
NOTES_DIR=$CODE_DIR/medgedocs/docs
if [ ! -d "$NOTES_DIR" ]; then
  git clone git@github.com:MatthewEdge/medgedocs.git $CODE_DIR/medgedocs
fi

alias cdnotes="cd $NOTES_DIR"

# CLI for interacting with note files
note() {
  DATE=$(date '+%Y-%m-%d')
  NOTE_NAME=${2:-$DATE}

  # Add extension if missing
  case "$NOTE_NAME" in
    *.md) ;;
    *) NOTE_NAME=$NOTE_NAME.md
  esac

  NOTE_PATH=$NOTES_DIR/$NOTE_NAME

  case $1 in
    new|n)
      $EDITOR $NOTE_PATH
      ;;
    cat|c)
      cat $NOTE_PATH
      ;;
    ls|l)
      ls $NOTES_DIR
      ;;
    open|o)
      $EDITOR $NOTE_PATH
      ;;
    del|d)
      rm $NOTE_PATH
      ;;
    rename|r)
      if [ -z "$2" ]; then echo "Usage: note rename NEW_NAME"; exit 1; fi
      # TODO allow file > file rename?
      mv $NOTE_PATH $NOTES_DIR/$2.md
      ;;
    *)
      echo "Usage: note CMD ARGS"
      echo "  new [NAME] - Create a new note, optionally with a given name"
      echo "  cat [NAME] - cat the contents of the given / current day's note"
      echo "  open [NAME] - open the contents of the given / current day's note in the shell EDITOR"
      echo "  list [NAME] - list notes in the Notes directory"
      echo "  del [NAME] - delete the given / current day's note"
      echo "  rename NEW_NAME - rename the current day's note to the given name"
      ;;
  esac
}

alias opennotes="open http://localhost:8000" # Mkdocs Container
alias todos="vim $NOTES_DIR/index.md"

## Notes Shell Completion
_note_completions() {
  local cur prev notes
  cur=${COMP_WORDS[COMP_CWORD]}
  prev=${COMP_WORDS[COMP_CWORD-1]}

  case ${COMP_CWORD} in
    1)
      # Complete `note` with subcommands
      COMPREPLY+=("new")
      COMPREPLY+=("cat")
      COMPREPLY+=("open")
      COMPREPLY+=("list")
      COMPREPLY+=("del")
      COMPREPLY+=("rename")
      ;;
    2)
      # Complete subcommands with ls of notes directory
      notes=$(command ls $NOTES_DIR)
      COMPREPLY=($(compgen -W "${notes}" -- ${cur}))
      ;;
    *)
      COMPREPLY=()
      ;;
  esac
}

complete -F _note_completions note


# Kubernetes
alias kgp="kubectl get pods"
alias kgpan="kubectl get pods --all-namespaces -o wide"
alias kgs="kubectl get svc"
alias k8t="$CODE_DIR/stream/lab-kit/k8t/k8t"

# Vault for Local
# mkdir -p $HOME/vault
# export VAULT_ADDR='http://127.0.0.1:8200'
# export VAULT_TOKEN=$(cat $HOME/vault/token)

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

# Golang
export GOPATH=$HOME/code/go
export PATH=$PATH:$GOPATH/bin
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

# Python
alias pip="python -m pip"
alias pipir="pip install -r requirements.txt"
