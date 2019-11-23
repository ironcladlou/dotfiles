setopt ignore_eof

function sback() {
  local f=$(mktemp)
  tmux capture-pane -pS - > $f
  code --goto $f:999999
}

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt extended_history
setopt inc_append_history_time
setopt hist_ignore_all_dups

eval "$(/opt/homebrew/bin/brew shellenv)"

export PATH="/opt/homebrew/opt/ruby/bin:$PATH:$HOME/bin:$HOME/.local/bin:/Applications/Visual Studio Code.app/Contents/Resources/app/bin:/Applications/Sublime Text.app/Contents/SharedSupport/bin"
fpath+=("$HOME/.zsh/pure")
fpath+=("$HOME/.zsh/functions")

#export CLOUDSDK_PYTHON="/usr/local/opt/python@3.8/libexec/bin/python"                                      
#source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"                         
#source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"  

autoload -Uz promptinit; promptinit
autoload -Uz compinit; compinit

alias s='subl'
alias oca='oc --as backplane-cluster-admin'

prompt pure

export CLICOLOR=1

source <(fzf --zsh)
eval "$(mise activate zsh)"
eval "$(zoxide init zsh)"


#eval "$(atuin init zsh --disable-up-arrow)"

# Hook up shell integration for wezterm.
#
# Although wezterm is mentioned here, the sequences used are not wezterm
# specific and may provide the same functionality for other terminals.  Most
# terminals are good at ignoring OSC sequences that they don't understand, but
# if not there are some bypasses:
#
# WEZTERM_SHELL_SKIP_ALL - disables all
# WEZTERM_SHELL_SKIP_SEMANTIC_ZONES - disables zones
# WEZTERM_SHELL_SKIP_CWD - disables OSC 7 cwd setting
# WEZTERM_SHELL_SKIP_USER_VARS - disable user vars that capture information
#                                about running programs

# shellcheck disable=SC2166
if [ -z "${BASH_VERSION-}" -a -z "${ZSH_NAME-}" ] ; then
  # Only for bash or zsh
  return 0
fi

if [ "${WEZTERM_SHELL_SKIP_ALL-}" = "1" ] ; then
  return 0
fi

if [[ $- != *i* ]] ; then
  # Shell integration is only useful in interactive sessions
  return 0
fi

case "$TERM" in
  linux | dumb )
    # Avoid terminals that don't like OSC sequences
    return 0
  ;;
esac

# This function emits an OSC 1337 sequence to set a user var
# associated with the current terminal pane.
# It requires the `base64` utility to be available in the path.
__wezterm_set_user_var() {
  if hash base64 2>/dev/null ; then
    if [[ -z "${TMUX-}" ]] ; then
      printf "\033]1337;SetUserVar=%s=%s\007" "$1" `echo -n "$2" | base64`
    else
      # <https://github.com/tmux/tmux/wiki/FAQ#what-is-the-passthrough-escape-sequence-and-how-do-i-use-it>
      # Note that you ALSO need to add "set -g allow-passthrough on" to your tmux.conf
      printf "\033Ptmux;\033\033]1337;SetUserVar=%s=%s\007\033\\" "$1" `echo -n "$2" | base64`
    fi
  fi
}

# This function emits an OSC 7 sequence to inform the terminal
# of the current working directory.  It prefers to use a helper
# command provided by wezterm if wezterm is installed, but falls
# back to a simple printf command otherwise.
__wezterm_osc7() {
  if hash wezterm 2>/dev/null ; then
    wezterm set-working-directory 2>/dev/null && return 0
    # If the command failed (perhaps the installed wezterm
    # is too old?) then fall back to the simple version below.
  fi
  printf "\033]7;file://%s%s\033\\" "${HOSTNAME}" "${PWD}"
}

# The semantic precmd and prexec functions generate semantic
# zones, marking up the prompt, the user input and the command
# output so that the terminal can better reason about the display.
__wezterm_semantic_precmd_executing=""
__wezterm_semantic_precmd() {
  local ret="$?"
  if [[ "$__wezterm_semantic_precmd_executing" != "0" ]] ; then
    __wezterm_save_ps1="$PS1"
    __wezterm_save_ps2="$PS2"
    # Markup the left and right prompts so that the terminal
    # knows that they are semantically prompt output.
    if [[ -n "$ZSH_NAME" ]] ; then
      PS1=$'%{\e]133;P;k=i\a%}'$PS1$'%{\e]133;B\a%}'
      PS2=$'%{\e]133;P;k=s\a%}'$PS2$'%{\e]133;B\a%}'
    else
      PS1='\[\e]133;P;k=i\a\]'$PS1'\[\e]133;B\a\]'
      PS2='\[\e]133;P;k=s\a\]'$PS2'\[\e]133;B\a\]'
    fi
    __wezterm_check_ps1="$PS1"
  fi
  if [[ "$__wezterm_semantic_precmd_executing" != "" ]] ; then
    # Report last command status
    printf "\033]133;D;%s;aid=%s\007" "$ret" "$$"
  fi
  # Fresh line and start the prompt
  if [[ -n "${BLE_VERSION-}" ]]; then
    # FreshLine breaks ble.sh's cursor position tracking.  Also, the cursor
    # position adjustment is already performed ble.sh so unnecessary here.  We
    # here only perform StartPrompt.
    printf "\033]133;P\007"
  else
    printf "\033]133;A;cl=m;aid=%s\007" "$$"
  fi
  __wezterm_semantic_precmd_executing=0
}

function __wezterm_semantic_preexec() {
  # Restore the original PS1/PS2 if set
  if [[ -n "${__wezterm_save_ps1+1}" && "${__wezterm_check_ps1-}" == "${PS1}" ]]; then
    PS1="$__wezterm_save_ps1"
    PS2="$__wezterm_save_ps2"
    unset __wezterm_save_ps1
  fi
  # Indicate that the command output begins here
  printf "\033]133;C;\007"
  __wezterm_semantic_precmd_executing=1
}

__wezterm_user_vars_precmd() {
  __wezterm_set_user_var "WEZTERM_PROG" ""
  __wezterm_set_user_var "WEZTERM_USER" "$(id -un)"

  # Indicate whether this pane is running inside tmux or not
  if [[ -n "${TMUX-}" ]] ; then
    __wezterm_set_user_var "WEZTERM_IN_TMUX" "1"
  else
    __wezterm_set_user_var "WEZTERM_IN_TMUX" "0"
  fi

  # You may set WEZTERM_HOSTNAME to a name you want to use instead
  # of calling out to the hostname executable on every prompt print.
  if [[ -z "${WEZTERM_HOSTNAME}" ]]; then
    if [[ -r /proc/sys/kernel/hostname ]]; then
      __wezterm_set_user_var "WEZTERM_HOST" "$(cat /proc/sys/kernel/hostname)"
    elif hash hostname 2>/dev/null; then
      __wezterm_set_user_var "WEZTERM_HOST" "$(hostname)"
    elif hash hostnamectl 2>/dev/null; then
      __wezterm_set_user_var "WEZTERM_HOST" "$(hostnamectl hostname)"
    else
      __wezterm_set_user_var "WEZTERM_HOST" "unknown"
    fi
  else
    __wezterm_set_user_var "WEZTERM_HOST" "${WEZTERM_HOSTNAME}"
  fi

  __wezterm_set_user_var "aws_profile" "${AWS_PROFILE}"

  if [[ -n "${KUBECONFIG-}" ]]; then
    local current_context=$(yq -r '.current-context' "$KUBECONFIG" | awk -F/ '{print $2"/"$3}')
    __wezterm_set_user_var "kube_context" "${current_context}"
  else
    __wezterm_set_user_var "kube_context" ""
  fi
}

__wezterm_user_vars_preexec() {
  # Tell wezterm the full command that is being run
  __wezterm_set_user_var "WEZTERM_PROG" "$1"
}

# Register the various functions; take care to perform osc7 after
# the semantic zones as we don't want to perturb the last command
# status before we've had a chance to report it to the terminal
if [[ -z "${WEZTERM_SHELL_SKIP_SEMANTIC_ZONES-}" ]]; then
  precmd_functions+=(__wezterm_semantic_precmd)
  preexec_functions+=(__wezterm_semantic_preexec)
fi

if [[ -z "${WEZTERM_SHELL_SKIP_USER_VARS-}" ]]; then
  precmd_functions+=(__wezterm_user_vars_precmd)
  preexec_functions+=(__wezterm_user_vars_preexec)
fi

if [[ -z "${WEZTERM_SHELL_SKIP_CWD-}" ]] ; then
   precmd_functions+=(__wezterm_osc7)
fi