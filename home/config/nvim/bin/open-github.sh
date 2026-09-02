#!/bin/bash

# Author: Nate Cheney
# Filename: open-github.sh
# Description: This script will open a git repository in github. 
# Usage: ./open-github.sh
# Options:
#

if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "The current working dir is not tracked by git. $PWD"
    exit 1

else
    origin=$(git remote get-url origin)

    if [[ $origin =~ ^git@github.com:.+$ ]]; then
        stripped1=${origin%.git}
        stripped2=${stripped1##*:}
        url="https://github.com/$stripped2"

    elif [[ $origin =~ ^https:\/\/github.com\/.+$ ]]; then
        url="${origin%.git}"

    elif [[ $origin =~ ^https:\/\/.+?@github.com\/.+$ ]]; then
        stripped1=${origin##*@}
        url="https://${stripped1%.git}"
    
    else 
        echo "The remote origin is not github"
        exit 1
    fi

    nohup xdg-open "$url" > /dev/null 2>&1 &
    echo "Opened $url."
fi

