#!/bin/bash
#
# Copyright (c) Safetrust, Inc. - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
#

VERSION="v0.0.2"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $DIR

# git add .

# git commit -m "Fix bug"

# git tag -fa $VERSION -m "Update $VERSION"

# git push origin :$VERSION

# git push origin $VERSION

if GIT_DIR=/path/to/repo/.git git rev-parse $VERSION >/dev/null 2>&1
then
    echo "Found tag"
else
    echo "Tag not found"
fi

# git push origin master