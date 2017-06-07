#!/bin/bash

set -eo pipefail

APP_NAME="$1"
shift
REGION="$1"
shift

case "$REGION" in
    usw)
        DEIS_BIN="deis"
        ;;
    euw)
        DEIS_BIN="deis"
        ;;
    virginia)
        DEIS_BIN="deis2"
        ;;
    tokyo)
        DEIS_BIN="deis2"
        ;;
    *)
        echo "Invalid region: $REGION"
        exit 1
        ;;
esac

if [[ ! -f "configs/${APP_NAME}.env" ]]; then
    echo "A config for ${APP_NAME} does not exist"
    exit 1
fi

CONFIG=$( DEIS_PROFILE="$REGION" $DEIS_BIN config --oneline -a "$APP_NAME" 2> /dev/null || true )
if [[ -z "$CONFIG" ]]; then
    echo "An error has occurred getting current config from Deis"
    exit 1
fi

ARGS=( "$APP_NAME" "$CONFIG" )
if [[ $# -gt 0 ]]; then
    ARGS+=( "$@" )
fi

bin/build-docker-image.sh 2> /dev/null
docker run --rm -v "$(pwd):/app" "$( bin/docker-image-tag.sh )" bin/config-diff.py "${ARGS[@]}"
