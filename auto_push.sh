#!/bin/bash

# 设置你的 Git 仓库根目录
REPO_DIR="/d/OpenROAD"

cd "$REPO_DIR" || { echo "仓库目录不存在！"; exit 1; }

git pull origin main

git add .

git commit -m "自动更新: $(date '+%Y-%m-%d %H:%M:%S')" || echo "没有新修改可提交"

git push origin main

echo "本地修改已自动提交并推送到远程仓库！"
