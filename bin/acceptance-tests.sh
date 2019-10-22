#!/bin/bash

docker run --rm -e MARK_EXPRESSION=headless mozorg/bedrock_test bin/run-integration-tests.sh
