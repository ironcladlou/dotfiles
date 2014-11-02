#!/bin/bash

# Preserve history
shopt -s histappend

# Prevent Ctrl-D from nuking shells
set -o ignoreeof

# Path setup
export GOPATH=$HOME/Projects/go
export PATH=/usr/local/bin:$PATH:$HOME/bin:$HOME/Applications/bin:$GOPATH/bin

# Aliases
alias rebash='source ~/.bashrc'
alias vi='vim'
alias rm='rm -i'
alias ls='ls -h --color'

# Fancy colors
source $HOME/dotfiles/thirdparty/base16-shell/base16-default.dark.sh

# Git prompt config
[ -f /usr/share/git-core/contrib/completion/git-prompt.sh ] && . /usr/share/git-core/contrib/completion/git-prompt.sh >/dev/null
[ -f /etc/bash_completion.d/git ] && . /etc/bash_completion.d/git >/dev/null
export GIT_PS1_SHOWDIRTYSTATE=true
export GIT_PS1_SHOWUNTRACKEDFILES=true

# Color setup
prompt_title="\033]0;\W\007\n\[\e[1;37m\]"
prompt_glyph="★"

c_reset="\[\e[0;39m\]"
c_user="\[\e[1;33m\]"
c_host="\[\e[1;36m\]"
c_pwd="\[\e[0;33m\]"
c_git="\[\e[0;36m\]"
c_glyph="\[\e[35;40m\]"
 
# Thy holy prompt.
PROMPT_COMMAND='history -a;PS1="${prompt_title}${c_glyph}${prompt_glyph}${c_reset} ${c_user}\u${c_reset}:${c_pwd}\w${c_reset}${c_git}$(__git_ps1 " (%s)")${c_reset} \[\e[1;37m\]${c_reset}\n$ "'

# Random functions
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

function gpull {
  local repo=`basename $(pwd)`
  local branch=`git rev-parse --abbrev-ref HEAD`
  local remote_branch=$1
  local remote_repo_branch=$(git rev-parse --abbrev-ref ${remote_branch}@{upstream} 2>/dev/null)

  if [ "$remote_repo_branch" != "" ]; then
    remote_repo_branch=$(echo $remote_repo_branch | sed 's/\//:/g')
  else
    remote_repo_branch=$remote_branch
  fi

  local url="https://github.com/ironcladlou/${repo}/compare/${remote_repo_branch}...${branch}?expand=1"
  xdg-open $url >/dev/null
}
