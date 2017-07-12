#!/bin/bash

GITHUB_API_ENDPOINT=$1
GITHUB_USER=$2
GITHUB_REPO=$3
GITHUB_TOKEN=$4

url="$JENKINS_URL"github-webhook/

data=$(cat <<-END
{
  "name": "web",
  "active": true,
  "events": [
    "*"
  ],
  "config": {
    "content_type": "form",
    "insecure_ssl": "0",
    "url": "$url"
  }
}
END
)

echo "Adding webhook to GitHub repo"

curl -X POST -H "Content-type: application/json" -d "$data" -u $GITHUB_USER:$GITHUB_TOKEN $GITHUB_API_ENDPOINT/repos/$GITHUB_USER/$GITHUB_REPO/hooks
