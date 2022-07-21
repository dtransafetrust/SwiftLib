#!/bin/bash
#
# Copyright (c) Safetrust, Inc. - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
#

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $DIR

RELEASE_VERSION="$1"
TAG_VERSION="v$1"
COMMIT_ID="$2"
GITHUB_ACCESS_TOKEN="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"

if [ -z "$GITHUB_ACCESS_TOKEN" ]; then
    echo "Please generate the Github Access Token and set it to 'GITHUB_ACCESS_TOKEN' env variable before run this script"
    exit 1
fi

REPO_NAME=SwiftLib
REPO_OWNER=dtransafetrust
FILE_NAME=ReleaseNotes.md


# Read ReleaseNotes.md

isCopying=false
message=""

echo "$FILE_NAME"

while read line; do
    if [[ $line == *"## [$RELEASE_VERSION]"* ]]; then
        isCopying=true

    elif [[ $line == *"## ["* ]]; then
        isCopying=false
    fi

    if [[ $isCopying == true && $line != *"## ["* ]];then
        message="$message\n$line"
    fi

done < $FILE_NAME

# Git tag

git tag -d $TAG_VERSION
git tag -a $TAG_VERSION $COMMIT_ID -m ""
git push origin :$TAG_VERSION
git push origin $TAG_VERSION

# Git release

bash git_release.sh $RELEASE_VERSION "master" "$message" $REPO_NAME $REPO_OWNER $GITHUB_ACCESS_TOKEN
