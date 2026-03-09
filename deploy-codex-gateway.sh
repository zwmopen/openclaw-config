#!/bin/bash

# codex-gateway 部署脚本
# 用于在腾讯云 Ubuntu 22.04 服务器上部署 codex-gateway

echo "=== codex-gateway 部署脚本 ==="
echo "开始部署 codex-gateway..."

# 更新系统包
echo "更新系统包..."
sudo apt update && sudo apt upgrade -y

# 安装 Git
echo "安装 Git..."
sudo apt install -y git

# 安装 Node.js 22（如果尚未安装）
echo "检查 Node.js 安装..."
if ! command -v node &> /dev/null; then
    echo "安装 Node.js 22..."
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt install -y nodejs
fi

# 验证 Node.js 安装
echo "验证 Node.js 版本..."
node -v
npm -v

# 克隆 codex-gateway 仓库
echo "克隆 codex-gateway 仓库..."
git clone https://github.com/Meltemi-Q/codex-gateway.git
cd codex-gateway

# 安装依赖
echo "安装依赖..."
npm install

# 运行设置脚本
echo "运行设置脚本..."
./setup.sh

# 创建系统服务
echo "创建系统服务..."
sudo cat > /etc/systemd/system/codex-gateway.service << EOF
[Unit]
Description=Codex Gateway
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/codex-gateway
ExecStart=/usr/bin/node index.mjs
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# 启用并启动服务
echo "启用并启动 codex-gateway 服务..."
sudo systemctl daemon-reload
sudo systemctl enable codex-gateway
sudo systemctl start codex-gateway

# 检查服务状态
echo "检查 codex-gateway 服务状态..."
sudo systemctl status codex-gateway

echo "=== 部署完成 ==="
echo "codex-gateway 已成功部署在腾讯云服务器上"
echo "服务状态：$(sudo systemctl is-active codex-gateway)"
echo "服务地址：http://127.0.0.1:8319"
echo "你可以通过以下命令管理服务："
echo "  - 启动服务：sudo systemctl start codex-gateway"
echo "  - 停止服务：sudo systemctl stop codex-gateway"
echo "  - 查看状态：sudo systemctl status codex-gateway"
echo "  - 查看日志：sudo journalctl -u codex-gateway -f"

# 提取 API 信息
echo "\n=== API 信息 ==="
echo "API 基础 URL: http://127.0.0.1:8319"
echo "API 密钥: PROXY_MANAGED (本地访问不需要密钥)"
echo "模型 ID 示例: gpt-5.3-codex, gpt-5.4"
echo "\n将以下配置添加到 OpenClaw 配置文件中:"
echo "\"codex-gateway\": {"
echo "  \"baseUrl\": \"http://127.0.0.1:8319\","
echo "  \"apiKey\": \"PROXY_MANAGED\","
echo "  \"api\": \"openai-compatible\","
echo "  \"models\": ["
echo "    {"
echo "      \"id\": \"gpt-5.3-codex\","
echo "      \"name\": \"GPT-5.3 Codex\","
echo "      \"reasoning\": true,"
echo "      \"input\": [\"text\"],"
echo "      \"contextWindow\": 128000,"
echo "      \"maxTokens\": 8192,"
echo "      \"cost\": {\"input\": 0, \"output\": 0}"
echo "    }"
echo "  ]"
echo "}"
