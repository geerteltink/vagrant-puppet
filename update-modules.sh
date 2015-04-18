#!/bin/bash

declare -A MODULES
MODULES["apache"]="git@github.com:puppetlabs/puppetlabs-apache.git"
MODULES["concat"]="git@github.com:puppetlabs/puppetlabs-concat.git"
MODULES["mysql"]="git@github.com:puppetlabs/puppetlabs-mysql.git"
MODULES["stdlib"]="git@github.com:puppetlabs/puppetlabs-stdlib.git"

# Get current dir
SCRIPT_PATH="${BASH_SOURCE[0]}";
if ([ -h "${SCRIPT_PATH}" ]) then
  while([ -h "${SCRIPT_PATH}" ]) do SCRIPT_PATH=`readlink "${SCRIPT_PATH}"`; done
fi
pushd . > /dev/null
cd `dirname ${SCRIPT_PATH}` > /dev/null
SCRIPT_PATH=`pwd`;
popd  > /dev/null

for K in "${!MODULES[@]}"; do

    TARGET=modules/$K
    GITREPO=${MODULES[$K]};

    # Check if target dir exists
    if [ ! -d $TARGET ]; then
        # Target does not exist, create it
        echo "Creating $TARGET"
        mkdir $TARGET
    elif [ "$(ls -A $TARGET)" ]; then
        if [ ! -d $TARGET/.git ]; then
            # Target exists but is no valid .git repo, clean it
            echo "Cleanup $TARGET"
            rm -rf $TARGET
            mkdir $TARGET
        fi
    fi

    # Check if .git dir exists
    if [ ! -d $TARGET/.git ]
    then
        echo "Cloning $GITREPO"
        git clone $GITREPO $TARGET
    fi

    # Goto target
    cd $TARGET

    # Get latest changes
    #git pull

    # Get new tags from the remote
    echo "Fetching tags"
    git fetch --tags

    # Get the latest tag name
    currentTag=$(git describe --tags)

    # Get the latest tag name
    latestTag=$(git describe --tags `git rev-list --tags --max-count=1`)

    if [ "$currentTag" != "$latestTag" ]; then
        # Checkout the latest tag
        echo "Checking out latest version: $latestTag"
        git checkout $latestTag
    else
        echo "$TARGET is on latest version: $latestTag"
    fi

    # Go back to script path
    cd $SCRIPT_PATH

done
