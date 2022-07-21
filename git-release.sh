#!/bin/bash

MESSAGE="$1"
VERSION="0.0.1"
DRAFT="false"
PRE="false"
BRANCH="master"
GITHUB_ACCESS_TOKEN="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"

# get repon name and owner
REPO_REMOTE=$(git config --get remote.origin.url)
echo "get repon name and owner $REPO_REMOTE"

if [ -z $REPO_REMOTE ]; then
	echo "Not a git repository"
	exit 1
fi

REPO_NAME=$(basename -s .git $REPO_REMOTE)
REPO_OWNER=$(git config --get user.name)

echo "REPO_NAME = $REPO_NAME"
echo "REPO_OWNER = $REPO_OWNER"

get args
echo 'get args'
while getopts v:m:b:draft:pre: option
do
	case "${option}"
		in
		v) VERSION="$OPTARG";;
		m) MESSAGE="$OPTARG";;
		b) BRANCH="$OPTARG";;
		draft) DRAFT="true";;
		pre) PRE="true";;
	esac
done

if [ $VERSION == "0" ]; then
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

echo "LINK = https://api.github.com/repos/dtransafetrust/SwiftLib/releases?access_token=$GITHUB_ACCESS_TOKEN"
API_RESPONSE_STATUS=$(curl -i -H "Authorization: token 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" --data "$API_JSON" -s -i https://api.github.com/repos/dtransafetrust/SwiftLib/releases)

echo "$API_RESPONSE_STATUS"
