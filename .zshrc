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
alias srczsh="source ~/.zshrc"

# ls
# Detect which `ls` flavor is in use
if ls --color > /dev/null 2>&1; then # GNU `ls`
  colorFlag="--color"
  export LS_COLORS='no=00:fi=00:di=01;31:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:'
else # macOS `ls`
  colorFlag="-G"
  export LSCOLORS='BxBxhxDxfxhxhxhxhxcxcx'
fi
alias ll="ls -alhF ${colorFlag}"
alias ls="command ls ${colorFlag}"

# Code folder
CODE_DIR=$HOME/code
mkdir -p $CODE_DIR

# Homebrew Tricks
alias brewdeps="brew leaves | xargs brew deps --installed --for-each"

# Git

# Echos the current directory's git branch name (if any)
# Thanks marksost/dotfiles !
function git_branch_name() {
  echo -e "$(git symbolic-ref --quiet --short HEAD 2> /dev/null || \
    git rev-parse --short HEAD 2> /dev/null || \
    echo '(unknown)')"
}

alias gg="git log --oneline --abbrev-commit --all --graph --decorate --color"
alias gs="git status"
alias ga="git add"
alias gc="git commit -m"
alias gd="git diff"
alias gfp="git fetch --prune && git pull"
alias grbm="git fetch origin && git rebase origin/main"
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
  NOTE_NAME=${2:-$DATE}.md
  NOTE_PATH=$NOTES_DIR/$NOTE_NAME

  case $1 in
    new|n)
      vim $NOTE_PATH
      ;;
    cat|c)
      cat $NOTE_PATH
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
      echo "  del [NAME] - delete the given / current day's note"
      echo "  rename NEW_NAME - rename the current day's note to the given name"
      exit 1
      ;;
  esac
}

alias opennotes="open http://localhost:8000" # Mkdocs Container
alias todos="vim $NOTES_DIR/index.md"

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
