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

alias dotfiles='cd $HOME/code/dotfiles'

# ls
alias ls="ls --color=auto"
alias ll="ls -lahGtr"

# VIM
# Old alias rewrites to save my tired brain
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

# Git

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

# Golang
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/code/go
export PATH=$PATH:$GOPATH/bin

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

# If amdgpu is not installed: https://amdgpu-install.readthedocs.io/en/latest/install-installing.html
#alias amdupdate="amdgpu-install --usecase=graphics,opencl --vulkan=amdvlk --accept-eula"

# Odin
export PATH=$PATH:$HOME/code/odin-dev-2026-07a

# Zig
export PATH=$PATH:$HOME/zig-0.14.1
# export PATH=$PATH:$HOME/zig-0.15.1

# Compression
compress() { tar -czf "${1%/}.tar.gz" "${1%/}"; }
alias decompress="tar -xzf"

# Transcode a video to a good-balance 1080p
transcode-video-1080p() {
  ffmpeg -i $1 -vf scale=1920:1080 -c:v libx264 -preset fast -crf 23 -c:a copy ${1%.*}-1080p.mp4
}

# Transcode a video to a good-balance 4K
transcode-video-4K() {
  ffmpeg -i $1 -c:v libx265 -preset slow -crf 24 -c:a aac -b:a 192k ${1%.*}-optimized.mp4
}

# inputrc
bind 'set meta-flag on'
bind 'set input-meta on'
bind 'set output-meta on'
bind 'set convert-meta off'

# bind 'set convert-meta off'
bind 'set completion-ignore-case on' # case-insensitive completion
bind 'set completion-prefix-display-length 2'
bind 'set show-all-if-ambiguous on'
bind 'set show-all-if-unmodified on'

# Immediately add a trailing slash when autocompleting symlinks to directories
# set mark-symlinked-directories on

# Do not autocomplete hidden files unless the pattern explicitly begins with a dot
bind 'set match-hidden-files off'

# Show all autocomplete results at once
# set page-completions off

# If there are more than 200 possible completions for a word, ask to show them all
bind 'set completion-query-items 200'

# Show extra file information when completing, like `ls -F` does
bind 'set visible-stats on'

# Be more intelligent when autocompleting by also looking at the text after
# the cursor. For example, when the current line is "cd ~/src/mozil", and
# the cursor is on the "z", pressing Tab will not autocomplete it to "cd
# ~/src/mozillail", but to "cd ~/src/mozilla". (This is supported by the
# Readline used by Bash 4.)
bind 'set skip-completed-text on'

# Coloring for Bash 4 tab completions.
bind 'set colored-stats on'

# History control
shopt -s histappend
HISTCONTROL=ignoreboth
HISTSIZE=32768
HISTFILESIZE="${HISTSIZE}"

# Autocompletion
if [[ ! -v BASH_COMPLETION_VERSINFO && -f /usr/share/bash-completion/bash_completion ]]; then
  source /usr/share/bash-completion/bash_completion
fi

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
