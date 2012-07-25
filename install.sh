#!/bin/bash

# For future reference
#case "$OSTYPE" in
#  solaris*) echo "SOLARIS" ;;
#  darwin*)  echo "OSX" ;; 
#  linux*)   echo "LINUX" ;;
#  bsd*)     echo "BSD" ;;
#  *)        echo "unknown: $OSTYPE" ;;
#esac

df_dir="$( cd "$( dirname "$0" )" && pwd )"

echo "Installing from dotfiles dir ${df_dir}"

for f in $(find "${df_dir}/bin" -type f -maxdepth 1); do
	target="${HOME}/bin/$(basename ${f})"

	if [ -f "${target}" ]; then
		echo "${target} is already installed, skipping"
	else
		echo "Installing ${f} => ${target}"
		ln -s $f $target
	fi
done
