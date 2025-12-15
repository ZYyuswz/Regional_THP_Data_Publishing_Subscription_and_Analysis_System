#!/bin/bash
# MQTT WebSocket 连接诊断脚本

echo "=== MQTT WebSocket 连接诊断 ==="
echo ""

# 1. 检查 Mosquitto 服务状态
echo "1. 检查 Mosquitto 服务状态:"
systemctl status mosquitto --no-pager -l 2>/dev/null || service mosquitto status 2>/dev/null || echo "  无法检查服务状态（可能需要 sudo）"
echo ""

# 2. 检查端口监听
echo "2. 检查端口监听状态:"
echo "   检查 1883 端口 (MQTT TCP):"
sudo netstat -tulpn | grep 1883 || echo "   ❌ 1883 端口未监听"
echo ""
echo "   检查 8083 端口 (MQTT WebSocket):"
sudo netstat -tulpn | grep 8083 || echo "   ❌ 8083 端口未监听"
echo ""

# 3. 检查 Mosquitto 配置文件
echo "3. 检查 Mosquitto 配置文件:"
CONFIG_FILES=(
    "/etc/mosquitto/mosquitto.conf"
    "/usr/local/etc/mosquitto/mosquitto.conf"
    "/opt/mosquitto/etc/mosquitto/mosquitto.conf"
    "$HOME/mosquitto/mosquitto.conf"
)

FOUND_CONFIG=false
for config_file in "${CONFIG_FILES[@]}"; do
    if [ -f "$config_file" ]; then
        echo "   找到配置文件: $config_file"
        echo "   内容:"
        cat "$config_file" | grep -E "(listener|port|websocket|protocol)" | sed 's/^/     /'
        FOUND_CONFIG=true
        break
    fi
done

if [ "$FOUND_CONFIG" = false ]; then
    echo "   ⚠️ 未找到配置文件，Mosquitto 可能使用默认配置"
fi
echo ""

# 4. 测试本地 WebSocket 连接
echo "4. 测试本地 WebSocket 连接:"
if command -v curl &> /dev/null; then
    echo "   测试 ws://localhost:8083:"
    curl -i -N -H "Connection: Upgrade" -H "Upgrade: websocket" -H "Sec-WebSocket-Version: 13" -H "Sec-WebSocket-Key: test" http://localhost:8083/ 2>&1 | head -5
else
    echo "   curl 未安装，跳过测试"
fi
echo ""

# 5. 检查防火墙
echo "5. 检查防火墙状态:"
if command -v firewall-cmd &> /dev/null; then
    echo "   Firewalld 状态:"
    sudo firewall-cmd --list-ports 2>/dev/null | grep -E "(8083|1883)" || echo "   未找到 8083 或 1883 端口规则"
elif command -v ufw &> /dev/null; then
    echo "   UFW 状态:"
    sudo ufw status | grep -E "(8083|1883)" || echo "   未找到 8083 或 1883 端口规则"
else
    echo "   未检测到常见防火墙服务"
fi
echo ""

# 6. 检查进程
echo "6. 检查 Mosquitto 进程:"
ps aux | grep mosquitto | grep -v grep || echo "   ⚠️ 未找到 Mosquitto 进程"
echo ""

echo "=== 诊断完成 ==="
echo ""
echo "如果 8083 端口未监听，需要配置 Mosquitto WebSocket 监听器"
echo "参考配置:"
echo "  listener 8083"
echo "  protocol websockets"

