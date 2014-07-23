#!/bin/bash

# Preserve history
shopt -s histappend

# Prevent Ctrl-D from nuking shells
set -o ignoreeof

# Platform detection
case "$OSTYPE" in
  darwin*)  platform="osx" ;;
  linux*)   platform="linux" ;;
  *)        platform="unknown" ;;
esac

# Source global definitions
[ ${platform} == "linux" ] && [ -f /etc/bashrc ] && . /etc/bashrc

# Path setup
export GOPATH=$HOME/Projects/go

# OSX path extensions
if [ ${platform} == "osx" ]; then
  export PATH=/usr/local/bin:$PATH

  # This must come after PATH is constructed
  if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
  fi
fi

export PATH=$PATH:$HOME/bin:$GOPATH/bin

# Aliases
alias vi='vim'
alias rebash='source ~/.bashrc'
alias rm='rm -i'
[ $platform == "linux" ] && alias rhc='run_proxied rhc'

# Fancy colors
[ $platform == "osx" ] && unset LS_COLORS

base16shell=$HOME/dotfiles/thirdparty/base16-shell
if [ -d $base16shell ]; then
  source ${base16shell}/base16-default.dark.sh
fi

# Random functions
function ghub {
  local branch=`git rev-parse --abbrev-ref HEAD`
  if [ ! -z "$branch" ]; then
    local repo=`basename $(pwd)`
    local url="https://github.com/ironcladlou/${repo}/tree/${branch}"
    echo "Launching ${url}"
    platform_open $url
  fi
}

function gcomp {
  local repo=`basename $(pwd)`
  local branch=`git rev-parse --abbrev-ref HEAD`
  local remote=`git rev-parse --abbrev-ref --symbolic-full-name @{u}`

  if [ -z "$remote}" ]; then return; fi

  local remote_array=(${remote//\// })
  local remote_repo=${remote_array[0]}
  local remote_branch=${remote_array[1]}

  local url="https://github.com/ironcladlou/${repo}/compare/${remote_repo}:${remote_branch}...${branch}?expand=1"

  echo "Launching ${url}"
  platform_open $url
}

function platform_open {
  if [ $platform == "linux" ]; then
    xdg-open $1 >/dev/null
  elif [ $platform == "osx" ]; then
    open $1
  else
    echo "Unsupported platform: $platform"
  fi
}

function run_proxied {
  export http_proxy='http://file.rdu.redhat.com:3128'
  export https_proxy='https://file.rdu.redhat.com:3128'

  "$@"

  unset http_proxy
  unset https_proxy
}
export -f run_proxied

####### Prompt setup

# Git support
[ $platform == "linux" ] && . /usr/share/git-core/contrib/completion/git-prompt.sh >/dev/null
export GIT_PS1_SHOWDIRTYSTATE=true
export GIT_PS1_SHOWUNTRACKEDFILES=true

# Color setup
prompt_title="\033]0;\W\007\n\[\e[1;37m\]"
prompt_glyph="★"

color_reset="\[\e[0;39m\]"
color_user="\[\e[1;33m\]"
color_host="\[\e[1;36m\]"
color_pwd="\[\e[0;33m\]"
color_git="\[\e[0;36m\]"
color_glyph="\[\e[35;40m\]"
 
# Thy holy prompt.
PROMPT_COMMAND='history -a;PS1="${prompt_title}${color_glyph}${prompt_glyph}${color_reset} ${color_user}\u${color_reset}:${color_pwd}\w${color_reset}${color_git}$(__git_ps1 " (%s)")${color_reset} \[\e[1;37m\]${color_reset}\n$ "'
