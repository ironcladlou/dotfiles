setopt ignore_eof

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt extended_history
setopt inc_append_history_time
setopt hist_ignore_all_dups

export PATH="$PATH:$HOME/bin:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
fpath+=("$HOME/.zsh/pure")
fpath+=("$HOME/.zsh/functions")

export CLOUDSDK_PYTHON="/usr/local/opt/python@3.8/libexec/bin/python"                                      
source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"                         
source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"  


autoload -Uz promptinit; promptinit
autoload -Uz compinit; compinit
autoload -Uz code
autoload -Uz goenv
autoload -Uz kc
autoload -Uz ac

prompt pure

eval "$(direnv hook zsh)"


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
