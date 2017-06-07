#!/bin/bash

set -exo pipefail

function image_exists() {
    docker history -q "${1}" > /dev/null 2>&1
    return $?
}

DOCKER_TAG=$( bin/docker-image-tag.sh )

if ! image_exists "$DOCKER_TAG"; then
    # build the docs builder
    docker build -t "$DOCKER_TAG" .
fi
