#!/bin/bash

set -exo pipefail

function image_exists() {
    docker history -q "${1}" > /dev/null 2>&1
    return $?
}

GIT_COMMIT="${GIT_COMMIT:-$(git rev-parse HEAD)}"
DOCKER_TAG="www-config-docs-builder:${GIT_COMMIT}"

# clean old docs
rm -rf site

if ! image_exists "$DOCKER_TAG"; then
    # build the docs builder
    docker build -t "$DOCKER_TAG" -f Dockerfile.docs .
fi

# generate new docs
docker run --rm --user $(id -u) -v "$(pwd):/app" "$DOCKER_TAG"
