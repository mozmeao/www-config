#!/bin/bash -xe

# make sure results dir exists or docker will create it
# and it will be owned by root
RESULTS_DIR="$PWD/results"
DOCKER_RESULTS_DIR="/app/results"
rm -rf "$RESULTS_DIR"
mkdir -p "$RESULTS_DIR"
docker run --rm -v "${RESULTS_DIR}:${DOCKER_RESULTS_DIR}" -u $(stat -c "%u:%g" "$RESULTS_DIR") \
  -e "BASE_URL=${BASE_URL}" \
  -e "RESULTS_PATH=${DOCKER_RESULTS_DIR}" \
  -e "MARK_EXPRESSION=headless" \
  -e "PYTEST_PROCESSES=5" \
  -e "PRIVACY=public restricted" \
  mozorg/bedrock_test:latest bin/run-integration-tests.sh
