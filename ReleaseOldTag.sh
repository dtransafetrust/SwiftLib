#!/bin/bash
#
# Copyright (c) Safetrust, Inc. - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
#

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $DIR

./ReleaseWithTag.sh 0.0.1 27cbaf8
sleep 3

./ReleaseWithTag.sh 0.0.2 2c29f59
sleep 3

./ReleaseWithTag.sh 0.0.4 019326a