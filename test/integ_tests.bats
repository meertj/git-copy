#!/bin/bash

# PLEASE PROVIDE A WORKING DIRECTORY THAT YOU AUTHORIZE git OPERATIONS to be performed in, READ/WRITE/EXECUTE ACCESS
authorized_workspace_directory="NOTAREALDIR/"

# TODO can I do this with submodules?
# git submodule add 

###### Global Variables ######
authorized_workspace_directory=~/Desktop/workspace
SAMPLEREPO1=git@github.com:meertj/dummy-project.git
SAMPLEDIR1="$authorized_workspace_directory/dummy-project"
SAMPLEREPO2=git@github.com:meertj/dummy-new-project.git
SAMPLEDIR2="$authorized_workspace_directory/dummy-new-project"
###### Global Variables ######


setup() {
    # get the containing directory of this file
    # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
    # as those will point to the bats executable's location or the preprocessed file respectively
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    # make executables in src/ visible to PATH
    PATH="$DIR/../src:$PATH"

    cd $authorized_workspace_directory

    echo Cloning sample repos
    git clone $SAMPLEREPO1
    git clone $SAMPLEREPO2
}

teardown() {
    echo Not yet implemented

    cd $authorized_workspace_directory

    # echo Cleaning up sample repos
    # rm -rf $SAMPLEDIR1
    # rm -rf $SAMPLEDIR2
}

get_commits() {
    commit="$(git log "$1"|grep ^commit|tail -1|awk '{print $2}')"^..HEAD
    echo commit
}

@test "Integ Test - One Commit" {
    arg1="$SAMPLEDIR1/" 
    arg2="$SAMPLEDIR2/" 
    arg3=test/test.cpp

    run git_copy_helper.sh $arg1 $arg2 $arg3
    
    sha1=get_commits "$arg1$arg3"
    sha2=
    
}

# @test "Integ Test - Multi Commit" {
#     echo Not yet implemented
# }
