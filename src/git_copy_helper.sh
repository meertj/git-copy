#!/bin/bash

## TODO: Basic UTs for Rust CLI
## TODO: Basic integ test for Windows
## TODO: Basic integ test for Unix/MacOS
## TODO: Easy install of dependencies (should just be git)

# Partial credit to http://blog.neutrino.es/2012/git-copy-a-file-or-directory-from-another-repository-preserving-history/ and ##

# input mapping - handling is done in the cli wrapper
# $1 = directory containing file or dir to copy
# $2 = directory to copy the file or dir to
# $3 = directory or file to copy

original_dir_and_file=$1+"/"+$3

# create tmp dir
mkdir /tmp/git-migrate-patches

cd $1

# export dir or file target
export target_patches=$3

# Save off these patches
git format-patch -o /tmp/git-migrate-patches $(git log $target_patches|grep ^commit|tail -1|awk '{print $2}')^..HEAD $target_patches

# Move to destination location
cd $2

# if dir
git am /tmp/git-migrate-patches

# if file or a dir not parallel
#git am -p$number

rm -rf /tmp/git-migrate-patches
