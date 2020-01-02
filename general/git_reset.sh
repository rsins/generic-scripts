#!/bin/bash

# To reset the current git repository from git and ignore all the local changes.

current_dir=`pwd`
current_branch=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
echo
read -p "Reset the current branch ($current_branch) in current folder (`basename $current_dir`) ? [y/n] " continue

if test "$continue" = "y" -o "$continue" = "Y"
then
   printf "\nContinue .. \n\n"

   git fetch --all
   git reset --hard origin/$current_branch
   git clean -f -d
else
   printf "\nResetting cancelled.\n"
fi

