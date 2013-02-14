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

# Add local binaries to the path
PATH=$PATH:$HOME/.local/bin:$HOME/bin

if [ ${platform} == "osx" ]; then
  PATH=/usr/local/bin:$PATH

  # This must come after PATH is constructed
  if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
  fi
fi

alias vi='vim'

####### OpenShift helpers

function run_proxied {
  export http_proxy='http://file.rdu.redhat.com:3128'
  export https_proxy='https://file.rdu.redhat.com:3128'

  $@

  unset http_proxy
  unset https_proxy
}

export -f run_proxied

if [ $platform == "linux" ]; then
  alias rhc='run_proxied rhc'
  alias rhc-create-app='run_proxied rhc-create-app'
fi

####### Prompt setup

prompt_title="\033]0;\W\007\n\[\e[1;37m\]"
prompt_glyph="★"

color_reset="\[\e[0;39m\]"
color_user="\[\e[1;33m\]"
color_host="\[\e[1;36m\]"
color_pwd="\[\e[0;33m\]"
color_git="\[\e[0;36m\]"
color_glyph="\[\e[35;40m\]"

export GIT_PS1_SHOWDIRTYSTATE=true
export GIT_PS1_SHOWUNTRACKEDFILES=true
 
# Thy holy prompt.
PROMPT_COMMAND='history -a;PS1="${prompt_title}${color_glyph}${prompt_glyph}${color_reset} ${color_user}\u${color_reset}:${color_pwd}\w${color_reset}${color_git}$(__git_ps1 " (%s)")${color_reset} \[\e[1;37m\]${color_reset}\n$ "'
