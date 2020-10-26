#!/usr/bin/env bash
set -x

if [ -z "${BASE_URL:-}" ];
then
    # No BASE_URL set, thus no tests run. Nothing to cleanup
    exit 0;
fi

# Copy artifacts from container to host to make them available for upload to GitLab
docker cp "bedrock-${CI_JOB_ID}:/app/tests/results" "results-${CI_JOB_ID}"

# Now that we copied artifact, remove container.
docker rm "bedrock-${CI_JOB_ID}"

if [ "${DRIVER}" = "Remote" ]; then
    docker-compose \
        -p "selenium-hub-${CI_JOB_ID}" \
        down --remove-orphans
fi
