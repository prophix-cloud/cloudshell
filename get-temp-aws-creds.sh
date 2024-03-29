#!/usr/bin/env bash

set -euo pipefail

creds=$(curl -H "Authorization: $AWS_CONTAINER_AUTHORIZATION_TOKEN" $AWS_CONTAINER_CREDENTIALS_FULL_URI 2>/dev/null)

ACCESS_KEY=$(echo ${creds} | jq -r .AccessKeyId)
SECRET_KEY=$(echo ${creds} | jq -r .SecretAccessKey)
SESSION_TOKEN=$(echo ${creds} | jq -r .Token)

yellow=$(tput setaf 3)
reset=$(tput sgr0)

echo -ne "\nHere are your temporary credentials. Paste them in your local shell.

${yellow}These credentials are valid for ~15mins${reset}

export AWS_ACCESS_KEY_ID='${ACCESS_KEY}'
export AWS_SECRET_ACCESS_KEY='${SECRET_KEY}'
export AWS_SESSION_TOKEN='${SESSION_TOKEN}'
\n"
