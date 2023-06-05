#!/bin/bash

## TODO: Basic integ tests
## TODO: Easy install of dependencies (should just be git)
## TODO: Script to add alias for git-copy

# Partial credit to http://blog.neutrino.es/2012/git-copy-a-file-or-directory-from-another-repository-preserving-history/

# input mapping - handling is done in the cli wrapper
# $1 = directory containing file or dir to copy
# $2 = directory to copy the file or dir to
# $3 = directory or file to copy
original_dir_and_file=$1+"/"+$3


######### BOILERPLATE CHECKS #########
# Check arg counts
if [ $# -lt 3 ];
then
  echo "$0: Missing arguments"
  exit 1
elif [ $# -gt 3 ];
then
  # shellcheck disable=SC2145
  echo "$0: Too many arguments: $@"
  exit 1
fi

## Check validity of arg 1 - broken
#if [ -d "$1" ];
#then
#  echo "$0: Bad argument: $1 DNE"
#  exit 1
#fi
# Check validity of arg 3
if [ -d "$3" ];
then
  echo "$0: Bad argument: $3 DNE"
  exit 1
fi
# Check validity of arg 1 + 3
if [ -e "$original_dir_and_file" ];
then
  echo "$0: Bad argument: $3 DNE in $1"
  exit 1
fi
######### BOILERPLATE CHECKS #########

cd "$1" || exit 1

# export dir or file target
export target_patches=$3

######### INITIAL COMMIT CHECK #########
# Credit: Tim von Münchhausen
INITCOMMIT=$(git rev-list --parents HEAD | egrep "^[a-f0-9]{40}$")
oldest_commit=$(git log $target_patches|grep ^commit|tail -1|awk '{print $2}')

if [[ $INITCOMMIT == $oldest_commit ]];
then
  # create tmp dir
  mkdir /tmp/git-migrate-patches

  echo File/dir of interest is included in initial commit
  git format-patch -1 -o /tmp/mergepatchs ${INITCOMMIT}

  # Move to destination location
  cd "$2" || exit 1
  git am /tmp/mergepatchs/0001*.patch
  
  rm -rf /tmp/git-migrate-patches
  cd "$1" || exit 1
fi
######### INITIAL COMMIT CHECK #########


## Normal Routing ##

cd "$1" || exit 1

# create tmp dir
mkdir /tmp/git-migrate-patches

# Save off these patches
git format-patch -o /tmp/git-migrate-patches $(git log $target_patches|grep ^commit|tail -1|awk '{print $2}')..HEAD $target_patches

# Move to destination location
cd "$2" || exit 1

# if dir
git am /tmp/git-migrate-patches/*.patch

# if file or a dir not parallel
# git am -p 1 /tmp/git-migrate-patches/*.patch

rm -rf /tmp/git-migrate-patches
