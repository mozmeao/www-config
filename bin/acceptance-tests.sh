#!/bin/bash -ex

if [ "${DRIVER}" = "Remote" ]; then
  # Start Selenium hub and NUMBER_OF_NODES (default 5) firefox nodes.
  # Waits until all nodes are ready and then runs tests
  SELENIUM_VERSION=${DOCKER_SELENIUM_VERSION:-"3.141.59-20200525"}
  docker pull selenium/hub:${SELENIUM_VERSION}
  docker pull selenium/node-firefox:${SELENIUM_VERSION}
  # start selenium grid hub
  docker run -d --rm -p 4444:4444 \
    --name bedrock-selenium-hub-${CI_COMMIT_SHA} \
    selenium/hub:${SELENIUM_VERSION}
  DOCKER_LINKS=(${DOCKER_LINKS[@]} --link bedrock-selenium-hub-${CI_COMMIT_SHA}:hub)
  SELENIUM_HOST="hub"
  SELENIUM_PORT="4444"

  # start selenium grid nodes
  for NODE_NUMBER in `seq ${NUMBER_OF_NODES:-5}`; do
    docker run -d --rm --shm-size 2g \
      --name bedrock-selenium-node-${NODE_NUMBER}-${CI_COMMIT_SHA} \
      ${DOCKER_LINKS[@]} \
      selenium/node-firefox:${SELENIUM_VERSION}
    while ! ${SELENIUM_READY}; do
      IP=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' bedrock-selenium-node-${NODE_NUMBER}-${CI_COMMIT_SHA}`
      CMD="docker run --rm --link bedrock-selenium-hub-${CI_COMMIT_SHA}:hub tutum/curl curl http://hub:4444/grid/api/proxy/?id=http://${IP}:5555 | grep 'proxy found'"
      if eval ${CMD}; then SELENIUM_READY=true; fi
    done
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
