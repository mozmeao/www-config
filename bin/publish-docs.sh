#!/bin/bash
set -e

cd site
touch .nojekyll
REV=$(git rev-parse HEAD)
git init
git config user.name "MozMEAO Robot"
git config user.email "pmac+github-mozmar-robot@mozilla.com"
git add .
git commit -m "Update docs to ${REV}"
if [[ -n "$GH_TOKEN" ]]; then
    git remote add mozilla "https://${GH_TOKEN}@github.com/mozmar/www-config.git"
else
    git remote add mozilla "git@github.com:mozmar/www-config.git"
fi
# Eat output so it doesn't spit out the sensitive GH_TOKEN if something goes wrong:
git push -q -f mozilla master:gh-pages > /dev/null 2>&1
