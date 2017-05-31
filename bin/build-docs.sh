#!/bin/bash

set -exo pipefail

bin/make-docs-config-page.py > docs/configs.md
mkdocs build
