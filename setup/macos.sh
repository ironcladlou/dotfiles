#!/bin/bash
set -e
set -u
set -o pipefail

function dotfiles::install_go {
  local version="$1"

  if [ -d $HOME/.go/$version ]; then
    return
  fi

  [[ -d $HOME/.go ]] || mkdir $HOME/.go

  echo "installing golang $version"
  local tarball="go${version}.darwin-amd64.tar.gz"
  wget "https://dl.google.com/go/${tarball}"
  tar zxf $tarball
  mv go $HOME/.go/$version
  rm -f $tarball
}

dotfiles::install_go 1.8.3
dotfiles::install_go 1.9
dotfiles::install_go 1.10.3
dotfiles::install_go 1.10.4
dotfiles::install_go 1.11

#~/Library/Application Support/Code/User/{keybindings,settings}.json
