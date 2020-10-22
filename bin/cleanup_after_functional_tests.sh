#!/usr/bin/env bash
set -x

if [ "${DRIVER}" = "Remote" ]; then
    docker-compose \
        -p "selenium-hub-${CI_JOB_ID}" \
        down --remove-orphans
fi
