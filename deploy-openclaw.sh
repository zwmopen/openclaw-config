#!/bin/bash

# OpenClaw 部署脚本
# 用于在腾讯云 Ubuntu 22.04 服务器上部署 OpenClaw

echo "=== OpenClaw 部署脚本 ==="
echo "开始部署 OpenClaw..."

# 更新系统包
echo "更新系统包..."
sudo apt update && sudo apt upgrade -y

# 安装 Node.js 22
echo "安装 Node.js 22..."
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs

# 验证 Node.js 安装
echo "验证 Node.js 版本..."
node -v
npm -v

# 安装 OpenClaw
echo "安装 OpenClaw..."
npm install -g openclaw@latest

# 验证 OpenClaw 安装
echo "验证 OpenClaw 版本..."
openclaw --version

# 初始化 OpenClaw 配置
echo "初始化 OpenClaw 配置..."
openclaw setup

# 创建启动脚本
echo "创建启动脚本..."
sudo cat > /etc/systemd/system/openclaw.service << EOF
[Unit]
Description=OpenClaw Gateway
After=network.target

[Service]
Type=simple
User=ubuntu
ExecStart=/usr/local/bin/openclaw gateway
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# 启用并启动 OpenClaw 服务
echo "启用并启动 OpenClaw 服务..."
sudo systemctl daemon-reload
sudo systemctl enable openclaw
sudo systemctl start openclaw

# 检查服务状态
echo "检查 OpenClaw 服务状态..."
sudo systemctl status openclaw

echo "=== 部署完成 ==="
echo "OpenClaw 已成功部署在腾讯云服务器上"
echo "服务状态：$(sudo systemctl is-active openclaw)"
echo "你可以通过以下命令管理服务："
echo "  - 启动服务：sudo systemctl start openclaw"
echo "  - 停止服务：sudo systemctl stop openclaw"
echo "  - 查看状态：sudo systemctl status openclaw"
echo "  - 查看日志：sudo journalctl -u openclaw -f"
