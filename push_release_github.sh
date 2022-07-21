#!/bin/bash
#
# Copyright (c) Safetrust, Inc. - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
#

echo "======== PUSH RELEASE TO GITHUB ========"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $DIR

RELEASE_VERSION="$1"
COMMIT_ID=$(git rev-parse --verify origin/master)

./release_with_tag.sh $RELEASE_VERSION $COMMIT_ID

echo "======== PUSH RELEASE TO GITHUB SUCCESSFULL!!! ========"