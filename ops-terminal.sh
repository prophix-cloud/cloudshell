#!/usr/bin/env bash

set -euo pipefail

configDir="~/ops-terminal.d"
mkdir -p "${configDir}"

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

touch "${configDir}/last-version"
lastLocalVersion=$(cat "${configDir}/last-version")

if [[ "${currentVersion}" != "${lastLocalVersion}" ]]; then
    aws s3 cp \
        "s3://${bucket}/ops-terminal" \
        "${configDir}/" \
        --region "${region}"

    chmod +x "${configDir}/ops-terminal"
    echo "${currentVersion}" > "${configDir}/last-version"
fi

# Start the app
${configDir}/ops-terminal
