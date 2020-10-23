#!/usr/bin/env bash
set -x

if [ -z "${BASE_URL:-}" ];
then
    # No BASE_URL set, thus no tests run. Nothing to cleanup
    exit 0;
fi

if [ "${DRIVER}" = "Remote" ]; then
    docker-compose \
        -p "selenium-hub-${CI_JOB_ID}" \
        down --remove-orphans
fi
