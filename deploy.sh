#!/bin/bash
set -ev
export TZ='Asia/Shanghai'

git config --global user.name "cjc7373"
git config --global user.email "niuchangcun@163.com"

# 获取以前的 commit 记录
git clone -b master https://github.com/cjc7373/cjc7373.github.io.git .deploy
# 这么移动是为了确保不受之前文件的影响
mv .deploy/.git/ public/
cd public
git checkout master

git add .
git commit -m "Site updated: `date +"%Y-%m-%d %H:%M:%S"`"

# 我也不知道 token 怎么用。。抄大佬的代码
git push "https://${token}@github.com/cjc7373/cjc7373.github.io.git" master:master --quiet