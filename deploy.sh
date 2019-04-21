#!/bin/bash
set -ev
export TZ='Asia/Shanghai'

git config --global user.name "cjc7373"
git config --global user.email "niuchangcun@163.com"

git clone -b master git@github.com:cjc7373/cjc7373.github.io.git .deploy
mv .deploy/.git/ public/
cd public
git checkout master

git add .
git commit -m "Site updated: `date +"%Y-%m-%d %H:%M:%S"`"

git push "https://${token}@github.com/cjc7373/cjc7373.github.io.git" master:master --quiet