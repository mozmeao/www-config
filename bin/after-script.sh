#!/usr/bin/env bash
set -x

UNIQUE_ID="${CI_COMMIT_SHA}-${CI_JOB_ID}"

if [ "${DRIVER}" = "Remote" ]; then
    docker-compose \
        -p "selenium-hub-${UNIQUE_ID}" \
        down --remove-orphans
fi
