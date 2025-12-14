#!/bin/bash
# 设置 MQTT 密码文件

echo "=== 设置 MQTT 密码文件 ==="
echo ""

# 密码文件路径
PASSWORD_FILE="/etc/mosquitto/passwd"
USERNAME="mqtt_server"
PASSWORD="mqtt_password"

# 检查密码文件是否存在
if [ -f "$PASSWORD_FILE" ]; then
    echo "密码文件已存在: $PASSWORD_FILE"
    echo "当前用户列表:"
    sudo cat "$PASSWORD_FILE"
    echo ""
    read -p "是否要添加/更新用户 $USERNAME? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "取消操作"
        exit 0
    fi
fi

# 创建或更新密码文件
echo "正在创建/更新用户: $USERNAME"
echo "密码: $PASSWORD"
echo ""

# 使用 mosquitto_passwd 命令
if command -v mosquitto_passwd &> /dev/null; then
    # 如果文件不存在，使用 -c 创建；如果存在，不使用 -c（会追加）
    if [ ! -f "$PASSWORD_FILE" ]; then
        echo "创建新的密码文件..."
        sudo mosquitto_passwd -c "$PASSWORD_FILE" "$USERNAME" <<< "$PASSWORD"
    else
        echo "更新现有密码文件..."
        sudo mosquitto_passwd "$PASSWORD_FILE" "$USERNAME" <<< "$PASSWORD"
    fi
    
    # 设置文件权限
    sudo chmod 600 "$PASSWORD_FILE"
    sudo chown mosquitto:mosquitto "$PASSWORD_FILE"
    
    echo ""
    echo "✅ 密码文件已创建/更新"
    echo "文件位置: $PASSWORD_FILE"
    echo "文件权限:"
    ls -l "$PASSWORD_FILE"
    echo ""
    echo "用户列表:"
    sudo cat "$PASSWORD_FILE"
    echo ""
    echo "⚠️  注意：密码文件中的密码是加密后的哈希值"
    echo ""
    echo "现在需要重启 Mosquitto 服务使配置生效:"
    echo "  sudo systemctl restart mosquitto"
else
    echo "❌ 错误: 未找到 mosquitto_passwd 命令"
    echo "请确保已安装 mosquitto 工具包"
    echo ""
    echo "Ubuntu/Debian: sudo apt-get install mosquitto-clients"
    echo "CentOS/RHEL: sudo yum install mosquitto"
    exit 1
fi

