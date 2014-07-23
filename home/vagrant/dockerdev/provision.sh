#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

yum update -y
yum install -y docker-io git vim golang e2fsprogs tmux

systemctl enable docker

usermod -a -G docker vagrant

sed -i s/Defaults.*requiretty/\#Defaults\ requiretty/g /etc/sudoers

sudo -u vagrant bash <<EOF
set -euo pipefail
IFS=$'\n\t'

cd ~
git clone https://github.com/ironcladlou/dotfiles.git

cd ~/dotfiles
git checkout unified

~/dotfiles/install
EOF
