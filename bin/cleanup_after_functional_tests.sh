#!/bin/bash -x

BIN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $BIN_DIR/set_git_env_vars.sh

docker stop bedrock-code-${CI_COMMIT_SHA}

for NODE_NUMBER in `seq ${NUMBER_OF_NODES:-5}`;
do
    docker stop bedrock-selenium-node-${NODE_NUMBER}-${CI_COMMIT_SHA}
done;

docker stop bedrock-selenium-hub-${CI_COMMIT_SHA}

# always report success
exit 0
