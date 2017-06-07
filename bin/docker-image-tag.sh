#!/bin/bash

set -eo pipefail

REQS_COMMIT=$( git log -n 1 --pretty=format:%H -- requirements.txt )
echo "www-config-builder:${REQS_COMMIT}"
