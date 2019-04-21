#!/bin/bash
set -ev
export TZ='Asia/Shanghai'

git clone -b master git@github.com:cjc7373/cjc7373.github.io.git .deploy
mv .deploy/.git/ public/
cd public
git checkout master

git add .
git commit -m "Site updated: `date +"%Y-%m-%d %H:%M:%S"`"

git push origin master:master --quiet