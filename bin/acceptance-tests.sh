#!/bin/bash -ex

docker pull mozorg/bedrock_test
docker run --rm \
    -e "DRIVER=${DRIVER}" \
    -e "SAUCELABS_USERNAME=${SAUCELABS_USERNAME}" \
    -e "SAUCELABS_API_KEY=${SAUCELABS_API_KEY}" \
    -e "BROWSER_NAME=${BROWSER_NAME}" \
    -e "BROWSER_VERSION=${BROWSER_VERSION}" \
    -e "PLATFORM=${PLATFORM}" \
    -e "MARK_EXPRESSION=${MARK_EXPRESSION}" \
    -e "BASE_URL=${BASE_URL}" \
    -e "PYTEST_PROCESSES=${PYTEST_PROCESSES:=4}" \
    ${TEST_IMAGE:=mozorg/bedrock_test} bin/run-integration-tests.sh
