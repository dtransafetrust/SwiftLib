#!/bin/bash
#
# Copyright (c) Safetrust, Inc. - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
#

RELEASE_VERSION="$1"
TAG_VERSION="v$1"
COMMIT_ID="$2"
REPO_NAME=SwiftLib
REPO_OWNER=dtransafetrust
GITHUB_ACCESS_TOKEN=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

git tag -d $TAG_VERSION
git tag -a $TAG_VERSION $COMMIT_ID -m ""
git push origin :$TAG_VERSION
git push origin $TAG_VERSION

filename="ReleaseNotes.md"
isCopying=false
message=""

while read line; do
    if [[ $line == *"## [$RELEASE_VERSION]"* ]]; then
        isCopying=true

    elif [[ $line == *"## ["* ]]; then
        isCopying=false
    fi

    if [[ $isCopying == true && $line != *"## ["* ]];then
        message="$message\n$line"
    fi

done < $filename

bash git-release.sh $RELEASE_VERSION "master" "$message" $REPO_NAME $REPO_OWNER $GITHUB_ACCESS_TOKEN