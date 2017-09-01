#!/bin/bash
set -e
set -u
set -o pipefail

function dotfiles::set_tz {
  if timedatectl status | grep EDT >/dev/null; then
    return
  fi

  local tz="America/New_York"
  echo "setting timezone to $tz"
  sudo timedatectl set-timezone $tz
}

function dotfiles::install_pkg {
  local pkg="$1"

  if rpm -q $pkg &>/dev/null; then
    return
  fi

  echo "installing $pkg"
  sudo dnf install -y $pkg
}

function dotfiles::setup_docker {
  sudo groupadd docker 2>/dev/null && echo "added docker group"
  if ! id -nG "$USER" | grep -qw docker; then
    sudo usermod -aG docker $USER && echo "added user to docker group"
  fi
  if [ ! -f /etc/systemd/system/multi-user.target.wants/docker.service ]; then
    echo "enabling docker service"
    sudo systemctl enable docker
  fi
}

function dotfiles::install_go {
  local version="$1"

  if [ -d $HOME/.go/$version ]; then
    return
  fi

  echo "installing golang $version"
  local tarball="go${version}.linux-amd64.tar.gz"
  wget "https://storage.googleapis.com/golang/${tarball}"
  mkdir $HOME/.go
  tar zxf $tarball
  mv go $HOME/.go/$version
  rm -f $tarball
}

function dotfiles::install_fzf {
  local version="0.17.0"
  
  if [ -f /usr/bin/fzf ]; then
    return
  fi

  echo "installing fzf"
  local tarball="fzf-${version}-linux_amd64.tgz"
  wget "https://github.com/junegunn/fzf-bin/releases/download/${version}/${tarball}"
  tar zxf $tarball
  sudo mv fzf /usr/bin/fzf
  rm -f $tarball
}

function dotfiles::install_direnv {
  if [ -f /usr/bin/direnv ]; then
    return
  fi

  local version="2.12.2"
  echo "installing direnv $version"
  sudo curl -Lo /usr/bin/direnv https://github.com/direnv/direnv/releases/download/v2.12.2/direnv.linux-amd64
  sudo chmod +x /usr/bin/direnv
}

dotfiles::set_tz

dotfiles::install_pkg bash-completion
dotfiles::install_pkg git
dotfiles::install_pkg docker
dotfiles::install_pkg tmux
dotfiles::install_pkg vim-enhanced
dotfiles::install_pkg nmap-ncat

dotfiles::setup_docker

dotfiles::install_go 1.8.3
dotfiles::install_fzf
dotfiles::install_direnv
