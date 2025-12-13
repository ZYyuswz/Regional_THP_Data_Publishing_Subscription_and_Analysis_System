#!/bin/bash
# 在服务器上更新代码的脚本

echo "正在更新代码..."

# 进入项目目录
cd /home/admin/Regional_THP_Data_Publishing_Subscription_and_Analysis_System

# 检查是否有未提交的更改
if [ -n "$(git status --porcelain)" ]; then
    echo "警告: 检测到未提交的更改"
    echo "当前更改的文件:"
    git status --short
    echo ""
    read -p "是否要暂存这些更改? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git stash
        echo "已暂存本地更改"
    else
        echo "取消更新"
        exit 1
    fi
fi

# 拉取最新代码
echo "正在从 GitHub 拉取最新代码..."
git pull origin main

# 如果使用 master 分支，改为:
# git pull origin master

if [ $? -eq 0 ]; then
    echo "✓ 代码更新成功！"
    
    # 如果有暂存的更改，询问是否恢复
    if [ -n "$(git stash list)" ]; then
        read -p "是否要恢复之前暂存的更改? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git stash pop
            echo "已恢复暂存的更改"
        fi
    fi
else
    echo "✗ 代码更新失败，请检查网络连接和 Git 配置"
    exit 1
fi

