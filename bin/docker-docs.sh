#!/bin/bash

set -exo pipefail

bin/build-docker-image.sh

# clean old docs
rm -rf site

# generate new docs
docker run --rm --user $(id -u) -v "$(pwd):/app" "$( bin/docker-image-tag.sh )"
