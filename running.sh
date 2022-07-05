#!/bin/bash
#
# Copyright (c) Safetrust, Inc. - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
#

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

git add .

git commit -m "Update pod spec"

git tag -fa 0.0.9

git push origin :0.0.9

git push origin 0.0.9