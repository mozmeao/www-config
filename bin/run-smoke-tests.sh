#!/bin/bash -xe

DRIVER=Remote
MARK_EXPRESSION=smoke

# Start Selenium hub and NUMBER_OF_NODES (default 5) firefox nodes.
# Waits until all nodes are ready and then runs tests against a local
# bedrock instance.

SELENIUM_VERSION=${SELENIUM_VERSION:-2.48.2}

docker pull selenium/hub:${SELENIUM_VERSION}
docker pull selenium/node-firefox:${SELENIUM_VERSION}

# start selenium grid hub
docker run -d --rm \
--name bedrock-selenium-hub-${GIT_COMMIT_SHORT} \
selenium/hub:${SELENIUM_VERSION}
DOCKER_LINKS=(${DOCKER_LINKS[@]} --link bedrock-selenium-hub-${GIT_COMMIT_SHORT}:hub)
SELENIUM_HOST="hub"

# start selenium grid nodes
for NODE_NUMBER in `seq ${NUMBER_OF_NODES:-5}`; do
  docker run -d --rm \
    --name bedrock-selenium-node-${NODE_NUMBER}-${GIT_COMMIT_SHORT} \
    ${DOCKER_LINKS[@]} \
    selenium/node-firefox:${SELENIUM_VERSION}
  while ! ${SELENIUM_READY}; do
    IP=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' bedrock-selenium-node-${NODE_NUMBER}-${GIT_COMMIT_SHORT}`
    CMD="docker run --rm --link bedrock-selenium-hub-${GIT_COMMIT_SHORT}:hub tutum/curl curl http://hub:4444/grid/api/proxy/?id=http://${IP}:5555 | grep 'proxy found'"
    if eval ${CMD}; then SELENIUM_READY=true; fi
  done
done

# make sure results dir exists or docker will create it
# and it will be owned by root
RESULTS_DIR="$PWD/results"
DOCKER_RESULTS_DIR="/app/results"
rm -rf "$RESULTS_DIR"
mkdir -p "$RESULTS_DIR"
docker run --rm -v "${RESULTS_DIR}:${DOCKER_RESULTS_DIR}" -u $(stat -c "%u:%g" "$RESULTS_DIR") \
  ${DOCKER_LINKS[@]} \
  -e "BASE_URL=${BASE_URL}" \
  -e "DRIVER=${DRIVER}" \
  -e "BROWSER_NAME=${BROWSER_NAME}" \
  -e "BROWSER_VERSION=${BROWSER_VERSION}" \
  -e "PLATFORM=${PLATFORM}" \
  -e "SELENIUM_HOST=${SELENIUM_HOST}" \
  -e "SELENIUM_PORT=${SELENIUM_PORT}" \
  -e "SELENIUM_VERSION=${SELENIUM_VERSION}" \
  -e "BUILD_TAG=${BUILD_TAG}" \
  -e "SCREEN_RESOLUTION=${SCREEN_RESOLUTION}" \
  -e "MARK_EXPRESSION=${MARK_EXPRESSION}" \
  -e "TESTS_PATH=${TESTS_PATH}" \
  -e "RESULTS_PATH=${DOCKER_RESULTS_DIR}" \
  -e "PYTEST_PROCESSES=5" \
  -e "PRIVACY=public restricted" \
  mozorg/bedrock_test:latest bin/run-integration-tests.sh
