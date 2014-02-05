#!/bin/bash

# Figure out where we are
df_dir="$( cd "$( dirname "$0" )" && pwd )"

common_bin_dir="${df_dir}/bin"
common_home_dir="${df_dir}/home"

# Platform detection
case "$OSTYPE" in
  solaris*) platform="solaris" ;;
  darwin*)  platform="osx" ;; 
  linux*)   platform="linux" ;;
  bsd*)     platform="bsd" ;;
  *)        platform="unknown" ;;
esac

echo "Target platform: ${platform}"

# Links binaries to $HOME/bin
function install_files {
  source_dir=$1
  target_dir=$2

  for f in $(find "${source_dir}" -maxdepth 1 -type f); do
    target="${target_dir}/$(basename ${f})"

    if [ -f "${target}" ]; then
      echo "  Reinstalling ${f} => ${target}"
      rm -rf $target
    else
      echo "  Installing ${f} => ${target}"  
    fi
    
    ln -s $f $target
  done
}

# todo: refactor this into a generic thing that acts
# upon an array

echo "Installing common binaries from ${common_bin_dir}"
install_files ${common_bin_dir} $HOME/bin

platform_bin_dir="${common_bin_dir}/platform/${platform}"
if [ -d "${platform_bin_dir}" ]; then
  echo "Installing ${platform} platform binaries from ${platform_bin_dir}"
  install_files ${platform_bin_dir} $HOME/bin
fi


echo "Installing common dotfiles from ${common_home_dir}"
install_files ${common_home_dir} $HOME

platform_home_dir="${common_home_dir}/platform/${platform}"
if [ -d "${platform_home_dir}" ]; then
  echo "Installing ${platform} platform dotfiles from ${platform_home_dir}"
  install_files ${platform_home_dir} $HOME
fi

echo "Setting up vim"
if [ -d ~/.vim ]; then rm ~/.vim; fi
ln -s ${common_home_dir}/.vim ~/.vim

