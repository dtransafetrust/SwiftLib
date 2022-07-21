#!/bin/bash
#
# Copyright (c) Safetrust, Inc. - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
#

RELEASE_VERSION="$1"
TAG_VERSION="v$1"
COMMIT_ID="$2"

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

bash git-release.sh -v $RELEASE_VERSION -m "$message" -b master