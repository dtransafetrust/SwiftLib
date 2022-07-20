#!/bin/bash
#
# Copyright (c) Safetrust, Inc. - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
#

TAG_VERSION="$1"
COMMIT_ID="$2"

if git rev-parse "$TAG_VERSION" >/dev/null 2>&1; then
    git tag -d $TAG_VERSION
    git tag -a $TAG_VERSION $COMMIT_ID -m ""
    git push origin :$TAG_VERSION
    git push origin $TAG_VERSION

else
    git tag $TAG_VERSION
    git push origin $TAG_VERSION
fi