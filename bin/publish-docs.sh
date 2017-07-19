#!/bin/bash
set -exo pipefail

cd site
touch .nojekyll
REV=$(git rev-parse HEAD)
git init
git config user.name "MozMEAO Robot"
git config user.email "pmac+github-mozmar-robot@mozilla.com"
git add .
git commit -m "Update docs to ${REV}"

if [[ -n "$GH_TOKEN" ]]; then
    git remote add mozilla "https://MozmarRobot:${GH_TOKEN}@github.com/mozmeao/www-config.git"
else
    git remote add mozilla "git@github.com:mozmeao/www-config.git"
fi

git push -q -f mozilla master:gh-pages
