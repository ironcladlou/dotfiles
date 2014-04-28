#!/bin/bash

# Platform detection
case "$OSTYPE" in
  solaris*) platform="solaris" ;;
  darwin*)  platform="osx" ;;
  linux*)   platform="linux" ;;
  bsd*)     platform="bsd" ;;
  *)        platform="unknown" ;;
esac

# Source global definitions
if [ ${platform} == "linux" ]; then
  if [ -f /etc/bashrc ]; then
    . /etc/bashrc
  fi
fi

# preserve history
shopt -s histappend

####### Path munging

export GOPATH=$HOME/Projects/go

# Add local binaries to the path
PATH=$PATH:$HOME/.local/bin:$HOME/bin:$HOME/local/bin:$GOPATH/bin


if [ ${platform} == "osx" ]; then
  PATH=/usr/local/bin:$PATH
  eval "$(rbenv init -)"

  # This must come after PATH is constructed
  if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
  fi
fi

alias vi='vim'
alias rebash='source ~/.bashrc'
alias rm='rm -i'
alias ls="ls -G"

####### Fun

function ghub {
  local branch=`git rev-parse --abbrev-ref HEAD`
  if [ ! -z "$branch" ]; then
    local repo=`basename $(pwd)`
    local url="https://github.com/ironcladlou/${repo}/tree/${branch}"
    echo "Launching ${url}"
    xdg-open $url >/dev/null
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
  xdg-open $url >/dev/null
}

function diskinventory {
   du -h -d 1 . 2>/dev/null | gsort -hr | head
}

function ddockeri {
  MNTROOT=/usr/local/src/projects

  docker run -i -t -v $MNTROOT/$(basename $PWD):/usr/local/src/$(basename $PWD) ironcladlou/$(basename $PWD) "$@"
}

####### OpenShift helpers

function run_proxied {
  export http_proxy='http://file.rdu.redhat.com:3128'
  export https_proxy='https://file.rdu.redhat.com:3128'

  "$@"

  unset http_proxy
  unset https_proxy
}

export -f run_proxied
alias rhc='run_proxied rhc'
alias rhc-int='run_proxied rhc --config=~/.openshift/express-int.conf'

####### Prompt setup

prompt_title="\033]0;\W\007\n\[\e[1;37m\]"
prompt_glyph="★"

color_reset="\[\e[0;39m\]"
color_user="\[\e[1;33m\]"
color_host="\[\e[1;36m\]"
color_pwd="\[\e[0;33m\]"
color_git="\[\e[0;36m\]"
color_glyph="\[\e[35;40m\]"

[ $platform == "linux" ] && . /usr/share/git-core/contrib/completion/git-prompt.sh >/dev/null
export GIT_PS1_SHOWDIRTYSTATE=true
export GIT_PS1_SHOWUNTRACKEDFILES=true
 
# Thy holy prompt.
PROMPT_COMMAND='history -a;PS1="${prompt_title}${color_glyph}${prompt_glyph}${color_reset} ${color_user}\u${color_reset}:${color_pwd}\w${color_reset}${color_git}$(__git_ps1 " (%s)")${color_reset} \[\e[1;37m\]${color_reset}\n$ "'
