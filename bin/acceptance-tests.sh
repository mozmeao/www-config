#!/bin/bash -ex

UNIQUE_ID="${CI_COMMIT_SHA}-${CI_JOB_ID}"
NUM_CPUS=$(grep -c %processor /proc/cpuinfo)
# Number of CPUs + 1 to have a hot spare.
NUM_BROWSER_NODES=$(( NUM_CPUS + 1 ))

if [ "${DRIVER}" = "Remote" ]; then
    docker-compose \
        -p "selenium-hub-${UNIQUE_ID}" \
        up -d selenium-hub

    docker-compose \
        -p "selenium-hub-${UNIQUE_ID}" \
        up -d --scale ${BROWSER_NAME}=${NUM_BROWSER_NODES} ${BROWSER_NAME}

    SELENIUM_HOST="grid"
    DOCKER_LINKS=(--link selenium-hub-${UNIQUE_ID}_selenium-hub_1:grid --net selenium-hub-${UNIQUE_ID}_default)

    IP=$(docker inspect selenium-hub-${UNIQUE_ID}_selenium-hub_1 | jq -r .[0].NetworkSettings.Networks[].IPAddress)
    SELENIUM_READY=$(curl -sSL http://${IP}:4444/wd/hub/status | jq .value.ready 2>&1 > /dev/null)
    while ! ${SELENIUM_READY}; do
        SELENIUM_READY=$(curl -sSL http://${IP}:4444/wd/hub/status | jq .value.ready 2>&1 > /dev/null)
        sleep 1s;
    done
fi

docker pull ${TEST_IMAGE:=mozmeao/bedrock_test}
docker run --rm \
    ${DOCKER_LINKS[@]} \
    -e "DRIVER=${DRIVER}" \
    -e "SAUCELABS_USERNAME=${SAUCELABS_USERNAME}" \
    -e "SAUCELABS_API_KEY=${SAUCELABS_API_KEY}" \
    -e "SELENIUM_HOST=${SELENIUM_HOST}" \
    -e "SELENIUM_PORT=${SELENIUM_PORT}" \
    -e "SELENIUM_VERSION=${SELENIUM_VERSION}" \
    -e "BROWSER_NAME=${BROWSER_NAME}" \
    -e "BROWSER_VERSION=${BROWSER_VERSION}" \
    -e "PLATFORM=${PLATFORM}" \
    -e "MARK_EXPRESSION=${MARK_EXPRESSION}" \
    -e "BASE_URL=${BASE_URL}" \
    -e "PYTEST_PROCESSES=${PYTEST_PROCESSES:=4}" \
    ${TEST_IMAGE} bin/run-integration-tests.sh

