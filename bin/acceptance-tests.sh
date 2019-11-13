#!/bin/bash


case $1 in
    chrome)
        BROWSER_NAME=chrome
        BROWSER_VERSION=latest
        PLATFORM="Windows 10"
        ;;
    firefox)
        BROWSER_NAME=firefox
        BROWSER_VERSION=latest
        PLATFORM="Windows 10"
        ;;
    ie)
        BROWSER_NAME="internet explorer"
        PLATFORM="Windows 10"
        ;;
    ie9)
        BROWSER_NAME="internet explorer"
        BROWSER_VERSION="9.0"
        PLATFORM="Windows 7"
        MARK_EXPRESSION=sanity
        ;;
    download)
        DRIVER=
        MARK_EXPRESSION=download
        ;;
    headless|*)
        DRIVER=
        MARK_EXPRESSION=headless
        ;;
esac

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
    mozorg/bedrock_test bin/run-integration-tests.sh
