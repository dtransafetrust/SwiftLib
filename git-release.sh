#!/bin/bash

VERSION="$1"
BRANCH="$2"
MESSAGE="$3"
REPO_NAME="$4"
REPO_OWNER="$5"
GITHUB_ACCESS_TOKEN="$6"
DRAFT="false"
PRE="false"

if [ $VERSION == "" ]; then
	echo "Usage: git-release -v <version> [-b <branch>] [-m <message>] [-draft] [-pre]"
	exit 1
fi

# set default message
echo 'set default message'
if [ "$MESSAGE" == "" ]; then
	MESSAGE=$(printf "Release of version %s" $VERSION)
fi

echo "MESSAGE = $MESSAGE"

API_JSON=$(printf '{"tag_name": "v%s","target_commitish": "%s","name": "v%s","body": "%s","draft": %s,"prerelease": %s}' "$VERSION" "$BRANCH" "$VERSION" "$MESSAGE" "$DRAFT" "$PRE" )
echo "API_JSON = $API_JSON"

echo "LINK = https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases"
API_RESPONSE_STATUS=$(curl -i -H "Authorization: token $GITHUB_ACCESS_TOKEN" --data "$API_JSON" -s -i https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases)

echo "$API_RESPONSE_STATUS"
