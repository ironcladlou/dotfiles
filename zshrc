setopt ignore_eof

bindkey  "^[[H"   beginning-of-line
bindkey  "^[[F"   end-of-line
bindkey  "^[[1~"   beginning-of-line
bindkey  "^[[4~"   end-of-line

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt extended_history
setopt inc_append_history_time
setopt hist_ignore_all_dups


export PATH="$PATH:$HOME/bin:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
fpath+=("$HOME/.zsh/pure")

autoload -Uz promptinit; promptinit
autoload -Uz compinit; compinit

prompt pure

eval "$(direnv hook zsh)"

