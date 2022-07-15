#!/bin/bash
#
# Copyright (c) Safetrust, Inc. - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
#

VERSION="0.1.3"

value=`cat release.yml`

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

git add .

git commit -m "Update release notes"

git tag -fa $VERSION -m $value

git push origin :$VERSION

git push origin $VERSION

git push origin master