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

open () {
   xdg-open "$@" >/dev/null 2>&1
}

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

# Compression
compress() { tar -czf "${1%/}.tar.gz" "${1%/}"; }
alias decompress="tar -xzf"

# Write iso file to sd card
iso2sd() {
  if [ $# -ne 2 ]; then
    echo "Usage: iso2sd <input_file> <output_device>"
    echo "Example: iso2sd ~/Downloads/ubuntu-25.04-desktop-amd64.iso /dev/sda"
    echo -e "\nAvailable SD cards:"
    lsblk -d -o NAME | grep -E '^sd[a-z]' | awk '{print "/dev/"$1}'
  else
    sudo dd bs=4M status=progress oflag=sync if="$1" of="$2"
    sudo eject $2
  fi
}

# Format an entire drive for a single partition using exFAT
format-drive() {
  if [ $# -ne 2 ]; then
    echo "Usage: format-drive <device> <name>"
    echo "Example: format-drive /dev/sda 'My Stuff'"
    echo -e "\nAvailable drives:"
    lsblk -d -o NAME -n | awk '{print "/dev/"$1}'
  else
    echo "WARNING: This will completely erase all data on $1 and label it '$2'."
    read -rp "Are you sure you want to continue? (y/N): " confirm

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      sudo wipefs -a "$1"
      sudo dd if=/dev/zero of="$1" bs=1M count=100 status=progress
      sudo parted -s "$1" mklabel gpt
      sudo parted -s "$1" mkpart primary 1MiB 100%

      partition="$([[ $1 == *"nvme"* ]] && echo "${1}p1" || echo "${1}1")"
      sudo partprobe "$1" || true
      sudo udevadm settle || true

      sudo mkfs.exfat -n "$2" "$partition"

      echo "Drive $1 formatted as exFAT and labeled '$2'."
    fi
  fi
}

# Transcode a video to a good-balance 1080p that's great for sharing online
transcode-video-1080p() {
  ffmpeg -i $1 -vf scale=1920:1080 -c:v libx264 -preset fast -crf 23 -c:a copy ${1%.*}-1080p.mp4
}

# Transcode a video to a good-balance 4K that's great for sharing online
transcode-video-4K() {
  ffmpeg -i $1 -c:v libx265 -preset slow -crf 24 -c:a aac -b:a 192k ${1%.*}-optimized.mp4
}

# Transcode any image to JPG image that's great for shrinking wallpapers
img2jpg() {
  img="$1"
  shift

  magick "$img" $@ -quality 95 -strip ${img%.*}-optimized.jpg
}

# Transcode any image to JPG image that's great for sharing online without being too big
img2jpg-small() {
  img="$1"
  shift

  magick "$img" $@ -resize 1080x\> -quality 95 -strip ${img%.*}-optimized.jpg
}

# Transcode any image to compressed-but-lossless PNG
img2png() {
  img="$1"
  shift

  magick "$img" $@ -strip -define png:compression-filter=5 \
    -define png:compression-level=9 \
    -define png:compression-strategy=1 \
    -define png:exclude-chunk=all \
    "${img%.*}-optimized.png"
}

# inputrc
set meta-flag on
set input-meta on
set output-meta on
set convert-meta off
set completion-ignore-case on
set completion-prefix-display-length 2
set show-all-if-ambiguous on
set show-all-if-unmodified on

# Arrow keys match what you've typed so far against your command history
"\e[A": history-search-backward
"\e[B": history-search-forward
"\e[C": forward-char
"\e[D": backward-char

# Immediately add a trailing slash when autocompleting symlinks to directories
set mark-symlinked-directories on

# Do not autocomplete hidden files unless the pattern explicitly begins with a dot
set match-hidden-files off

# Show all autocomplete results at once
set page-completions off

# If there are more than 200 possible completions for a word, ask to show them all
set completion-query-items 200

# Show extra file information when completing, like `ls -F` does
set visible-stats on

# Be more intelligent when autocompleting by also looking at the text after
# the cursor. For example, when the current line is "cd ~/src/mozil", and
# the cursor is on the "z", pressing Tab will not autocomplete it to "cd
# ~/src/mozillail", but to "cd ~/src/mozilla". (This is supported by the
# Readline used by Bash 4.)
set skip-completed-text on

# Coloring for Bash 4 tab completions.
set colored-stats on

# History control
shopt -s histappend
HISTCONTROL=ignoreboth
HISTSIZE=32768
HISTFILESIZE="${HISTSIZE}"

# Autocompletion
if [[ ! -v BASH_COMPLETION_VERSINFO && -f /usr/share/bash-completion/bash_completion ]]; then
  source /usr/share/bash-completion/bash_completion
fi

# Ensure command hashing is off for mise
set +h


cdcode() {
    cd $HOME/code/$1
}
_cdcode_completions() {
    local cur prev
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}
    local folders

    case ${COMP_CWORDS} in
        1) # Root command
            folders=$(command ls $HOME/code)
            COMPREPLY=($(compgen -W "${folders}" -- ${cur}))
            ;;
        # If we had subcommands - 2) here
        *)
            COMPREPLY=()
            ;;
    esac
}
# Register complete function to the command
complete _cdcode_completions cdcode
