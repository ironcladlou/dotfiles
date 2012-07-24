# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" # Load RVM function


function run_proxied {
  export http_proxy='file.rdu.redhat.com:3128'
  export https_proxy='file.rdu.redhat.com:3128'

  $@

  unset http_proxy
  unset https_proxy 
}

function settitle() { echo -n -e "\033]0;$1\007"; }
export -f settitle

alias rhc='run_proxied rhc'
alias rhc-create-app='run_proxied rhc-create-app'


# Configure colors, if available.
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
  c_reset='\[\e[0m\]'
  c_user='\[\033[1;33m\]'
  c_path='\[\e[0;33m\]'
  c_git_clean='\[\e[0;36m\]'
  c_git_dirty='\[\e[0;35m\]'
else
  c_reset=
  c_user=
  c_path=
  c_git_clean=
  c_git_dirty=
fi
 
# Function to assemble the Git part of our prompt.
git_prompt ()
{
  if ! git rev-parse --git-dir > /dev/null 2>&1; then
      return 0
  fi
 
  git_branch=$(git branch 2>/dev/null| sed -n '/^\*/s/^\* //p')
 
  if git diff --quiet 2>/dev/null >&2; then
      git_color="$c_git_clean"
  else
      git_color="$c_git_dirty"
  fi
 
  echo " [$git_color$git_branch${c_reset}]"
}
 
# Thy holy prompt.
PROMPT_COMMAND='PS1="\033]0;\W\007${c_user}\u${c_reset}:${c_path}\W${c_reset}$(git_prompt)\$ "'
