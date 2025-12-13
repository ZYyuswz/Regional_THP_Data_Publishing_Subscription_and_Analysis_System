// 配置文件
// 请根据你的服务器实际地址修改以下配置

// 后端 API 地址（publisher-end 的 Flask 服务地址）
// 如果服务器有公网 IP，请使用公网 IP；如果是内网，请使用内网 IP
// 注意：前端在本地运行时，需要使用服务器的公网 IP 才能访问
export const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://139.224.192.45:3000'

// MQTT WebSocket 地址
// 注意：前端在本地运行时，需要使用服务器的公网 IP 才能访问
export const MQTT_WS_URL = import.meta.env.VITE_MQTT_WS_URL || 'ws://139.224.192.45:8083'

// MQTT 认证信息
export const MQTT_USERNAME = import.meta.env.VITE_MQTT_USERNAME || 'mqtt_server'
export const MQTT_PASSWORD = import.meta.env.VITE_MQTT_PASSWORD || 'mqtt_password'

