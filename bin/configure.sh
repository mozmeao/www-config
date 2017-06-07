#!/bin/bash

set -eo pipefail

RET_VAL=1

echo "Configuring ${DEIS_APP} in ${DEIS_PROFILE}"

# collect the variables that need to change
ENV_VALUES=( $( bin/config-diff.sh "${DEIS_APP}" "${DEIS_PROFILE}" || true ) )

if [[ "${#ENV_VALUES[@]}" == 0 ]]; then
    echo "No changes required"
else
    # send output to bit bucket since it will potentially expose secrets
    $DEIS_BIN config:set -a "$DEIS_APP" "${ENV_VALUES[@]}" > /dev/null 2>&1
    echo "Set new config for ${DEIS_APP} in ${DEIS_PROFILE}:"
    echo "${ENV_VALUES[@]}"
    RET_VAL=0
fi

# collect the variables that need to be deleted
DEL_VALUES=( $( bin/config-diff.sh "${DEIS_APP}" "${DEIS_PROFILE}" --delete || true ) )

if [[ "${#DEL_VALUES[@]}" == 0 ]]; then
    echo "No deletions required"
else
    # send output to bit bucket since it will potentially expose secrets
    $DEIS_BIN config:unset -a "$DEIS_APP" "${DEL_VALUES[@]}" > /dev/null 2>&1
    echo "Unset config for ${DEIS_APP} in ${DEIS_PROFILE}:"
    echo "${DEL_VALUES[@]}"
    RET_VAL=0
fi

exit $RET_VAL
