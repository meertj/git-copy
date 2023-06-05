#!/bin/bash

# PLEASE PROVIDE A WORKING DIRECTORY THAT YOU AUTHORIZE git OPERATIONS to be performed in, READ/WRITE/EXECUTE ACCESS
authorized_workspace_directory="NOTAREALDIR/"

# TODO can I do this with submodules?
# git submodule add 

###### Global Variables ######
SAMPLEDIR1=git@github.com:meertj/dummy-project.git
SAMPLEDIR2=git@github.com:meertj/dummy-new-project.git
authorized_workspace_directory=~/Desktop/workspace
###### Global Variables ######


setup() {
    # get the containing directory of this file
    # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
    # as those will point to the bats executable's location or the preprocessed file respectively
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    # make executables in src/ visible to PATH
    PATH="$DIR/../src:$PATH"

    cd $authorized_workspace_directory

    git clone $SAMPLEDIR1

    git clone $SAMPLEDIR2
}


@test "Integ Test - One Commit" {
    # notice the missing ./
    # As we added src/ to $PATH, we can omit the relative path to `src/project.sh`.
    project.sh
}

@test "Integ Test - Multi Commit" {
    echo Not yet implemented
}
