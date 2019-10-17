#!/bin/bash

docker run --rm -e MARK_EXPRESSION=headless mozorg/bedrock_test:${GIT_COMMIT} bin/run-integration-tests.sh
