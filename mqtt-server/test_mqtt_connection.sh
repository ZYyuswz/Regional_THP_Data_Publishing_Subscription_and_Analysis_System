#!/bin/bash
# MQTT 连接测试脚本

echo "=== MQTT 连接测试 ==="
echo ""

# 配置
BROKER="localhost"
TCP_PORT=1883
WS_PORT=8083
USERNAME="mqtt_server"
PASSWORD="tongji"
TOPIC="test/topic"

echo "1. 测试 TCP MQTT 连接 (端口 1883):"
echo "   这是标准的 MQTT 协议，用于后端连接"
echo ""
echo "   在终端 1 运行（订阅）:"
echo "   mosquitto_sub -h $BROKER -p $TCP_PORT -u $USERNAME -P $PASSWORD -t \"$TOPIC\" -v"
echo ""
echo "   在终端 2 运行（发布）:"
echo "   mosquitto_pub -h $BROKER -p $TCP_PORT -u $USERNAME -P $PASSWORD -t \"$TOPIC\" -m \"Hello MQTT\""
echo ""

echo "2. 测试 WebSocket 连接 (端口 8083):"
echo "   这是 WebSocket 协议，用于前端连接"
echo "   mosquitto_sub/mosquitto_pub 不支持 WebSocket，需要使用其他工具"
echo ""
echo "   方法 1: 使用 Python 测试（推荐）"
echo "   创建测试脚本 test_ws.py:"
cat << 'EOF'
import paho.mqtt.client as mqtt
import time

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("✅ WebSocket 连接成功！")
        client.subscribe("test/topic")
    else:
        print(f"❌ 连接失败，错误码: {rc}")

def on_message(client, userdata, msg):
    print(f"📨 收到消息: {msg.topic} -> {msg.payload.decode()}")

client = mqtt.Client(transport='websockets')
client.username_pw_set('mqtt_server', 'tongji')
client.on_connect = on_connect
client.on_message = on_message

print("🔌 正在连接 WebSocket...")
client.connect('localhost', 8083, 60)
client.loop_start()

time.sleep(2)
print("📤 发布测试消息...")
client.publish('test/topic', 'Hello from WebSocket!')

time.sleep(2)
client.loop_stop()
client.disconnect()
EOF
echo ""
echo "   运行: python3 test_ws.py"
echo ""

echo "3. 检查密码文件:"
if [ -f "/etc/mosquitto/passwd" ]; then
    echo "   ✅ 密码文件存在"
    echo "   用户列表:"
    sudo cat /etc/mosquitto/passwd | sed 's/^/     /'
else
    echo "   ❌ 密码文件不存在"
fi
echo ""

echo "4. 检查服务状态:"
systemctl is-active mosquitto >/dev/null 2>&1 && echo "   ✅ Mosquitto 服务运行中" || echo "   ❌ Mosquitto 服务未运行"
echo ""

echo "5. 检查端口监听:"
echo "   TCP 1883:"
sudo netstat -tulpn | grep 1883 | sed 's/^/     /' || echo "     ❌ 未监听"
echo "   WebSocket 8083:"
sudo netstat -tulpn | grep 8083 | sed 's/^/     /' || echo "     ❌ 未监听"
echo ""

