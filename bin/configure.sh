#!/bin/bash

set -ex

echo "Configuring ${DEIS_APP} in ${DEIS_PROFILE}"

ENV_FILES=(
  "configs/global.env"
  "configs/${DEIS_PROFILE}.env"
  "configs/${DEIS_APP}.env"
)

# reads which ever of the above files exist in order and combines values
ENV_VALUES=( $(bin/envcat "${ENV_FILES[@]}") )

# send output to bit bucket since it will potentially expose secrets
$DEIS_BIN config:set -a "$DEIS_APP" "${ENV_VALUES[@]}" > /dev/null 2>&1 || true
