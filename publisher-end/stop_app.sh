#!/bin/bash
# 停止 app.py 进程的脚本

echo "正在查找占用端口 3000 的进程..."
# 查找占用端口 3000 的进程
PID=$(lsof -ti:3000 2>/dev/null || netstat -tulpn 2>/dev/null | grep :3000 | awk '{print $7}' | cut -d'/' -f1 | head -1)

if [ -z "$PID" ]; then
    echo "未找到占用端口 3000 的进程"
else
    echo "找到进程 PID: $PID"
    kill -9 $PID 2>/dev/null
    echo "已强制关闭进程 $PID"
    sleep 1
fi

echo ""
echo "正在查找所有 app.py 相关进程..."
# 查找所有运行 app.py 的进程
APP_PIDS=$(ps aux | grep '[a]pp.py' | awk '{print $2}')

if [ -z "$APP_PIDS" ]; then
    echo "未找到运行中的 app.py 进程"
else
    echo "找到以下 app.py 进程:"
    ps aux | grep '[a]pp.py'
    echo ""
    for pid in $APP_PIDS; do
        echo "正在关闭进程 $pid..."
        kill -9 $pid 2>/dev/null
    done
    echo "已关闭所有 app.py 进程"
fi

echo ""
echo "再次检查端口 3000..."
if lsof -ti:3000 >/dev/null 2>&1 || netstat -tulpn 2>/dev/null | grep -q :3000; then
    echo "警告: 端口 3000 仍被占用，可能需要手动检查"
else
    echo "✓ 端口 3000 已释放"
fi

echo ""
echo "完成！现在可以重新运行 app.py 了"

