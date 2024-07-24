#!/usr/bin/env bash

set -euo pipefail

mkdir -p "~/.ops-terminal"

bucket=""
region="us-east-1"

accountId=$(aws sts get-caller-identity --query "Account" --output text)
if [[ "${accountId}" == "816621830681" ]]; then
    bucket="px-ops-terminal-uat"
else
    bucket="px-ops-terminal-prod"
fi

currentVersion=$(aws s3api list-object-versions \
    --region "${region}" \
    --bucket "${bucket}" \
    --prefix ops-terminal \
    --query 'Versions[?IsLatest].VersionId' \
    --output text)

touch "~/.ops-terminal/last-version"
lastLocalVersion=$(cat "~/.ops-terminal/last-version")

if [[ "${currentVersion}" != "${lastLocalVersion}" ]]; then
    aws s3 cp \
        "s3://${bucket}/ops-terminal" \
        "~/.ops-terminal/" \
        --region "${region}"

    chmod +x "~/.ops-terminal/ops-terminal"
    echo "${currentVersion}" > "~/.ops-terminal/last-version"
fi

# Start the app
~/.ops-terminal/ops-terminal
