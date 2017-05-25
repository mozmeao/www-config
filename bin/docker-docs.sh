#!/bin/bash

set -exo pipefail

# clean old docs
rm -rf site

# build the docs builder
docker build -t www-config-docs-builder -f Dockerfile.docs .

# generate new docs
docker run --rm --user $(id -u) -v "$(pwd):/app" www-config-docs-builder
