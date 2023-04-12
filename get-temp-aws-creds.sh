#!/usr/bin/env bash

set -euo pipefail

curl -H "Authorization: $AWS_CONTAINER_AUTHORIZATION_TOKEN" $AWS_CONTAINER_CREDENTIALS_FULL_URI 2>/dev/null > /tmp/credentials

ACCESS_KEY=`cat /tmp/credentials| jq -r .AccessKeyId`
SECRET_KEY=`cat /tmp/credentials| jq -r .SecretAccessKey`
SESSION_TOKEN=`cat /tmp/credentials| jq -r .Token`
rm -f /tmp/credentials

echo -ne "\nHere are your temporary credentials. Paste them in your shell.

export AWS_ACCESS_KEY_ID='${ACCESS_KEY}'
export AWS_SECRET_ACCESS_KEY='${SECRET_KEY}'
export AWS_SESSION_TOKEN='${SESSION_TOKEN}'
\n"
