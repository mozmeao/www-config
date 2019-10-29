#!/bin/bash

DRIVER=SauceLabs
MARK_EXPRESSION="not headless and not download"

case $1 in
    chrome)
        BROWSER_NAME=chrome
        PLATFORM="Windows 10"
        ;;
    firefox)
        BROWSER_NAME=firefox
        BROWSER_VERSION="57.0"
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
    headless)
        DRIVER=
        MARK_EXPRESSION=headless
        ;;
    *)
        set +x
        echo "Missing or invalid required argument"
        echo
        echo "Usage: run_integration_tests.sh <chrome|firefox|ie{,6,7}|headless>"
        exit 1
        ;;
esac

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
