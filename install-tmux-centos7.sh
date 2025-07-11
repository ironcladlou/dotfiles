#!/bin/bash

# install deps
sudo yum install -y gcc kernel-devel make ncurses-devel

# DOWNLOAD SOURCES FOR LIBEVENT AND MAKE AND INSTALL
curl -OL https://github.com/libevent/libevent/releases/download/release-2.1.8-stable/libevent-2.1.8-stable.tar.gz
tar -xvzf libevent-2.1.8-stable.tar.gz
cd libevent-2.1.8-stable
./configure --prefix=/usr/local
make
sudo make install
cd ..

# DOWNLOAD SOURCES FOR TMUX AND MAKE AND INSTALL
curl -OL https://github.com/tmux/tmux/releases/download/2.7/tmux-2.7.tar.gz
tar -xvzf tmux-2.7.tar.gz
cd tmux-2.7
LDFLAGS="-L/usr/local/lib -Wl,-rpath=/usr/local/lib" ./configure --prefix=/usr/local
make
sudo make install
