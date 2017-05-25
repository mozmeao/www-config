#!/bin/bash -x

for NODE_NUMBER in `seq ${NUMBER_OF_NODES:-5}`;
do
    docker stop bedrock-selenium-node-${NODE_NUMBER}-${GIT_COMMIT_SHORT}
done;

docker stop bedrock-selenium-hub-${GIT_COMMIT_SHORT}

# always report success
exit 0
