#!/bin/bash

# 本地仓库路径
REPO_DIR="D:\OpenROAD\OpenROAD-flow-scripts"

# 进入仓库目录
cd "$REPO_DIR" || { echo "仓库目录不存在！"; exit 1; }

# 拉取最新代码，防止冲突
git pull origin main

# 添加所有修改（新文件、修改、删除）
git add .

# 提交，提交信息带日期
git commit -m "自动更新: $(date '+%Y-%m-%d %H:%M:%S')"

# 推送到远程仓库（默认 main 分支）
git push origin main

echo "本地修改已自动提交并推送到远程仓库！"
