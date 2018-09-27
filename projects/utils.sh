#/bin/bash

function dotfiles::direnv::setup_gopath {
  if [ -z "$1" ]; then
    return
  fi
  local go_version="$1"
  export GOROOT="$HOME/.go/${go_version}"
  export GOPATH="$(expand_path .)"
  export PATH="${PATH}:${GOROOT}/bin:${GOPATH}/bin"
}
