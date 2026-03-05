# OpenClaw 部署到联通云服务器脚本
# 使用方法：在本地运行此脚本，自动部署到联通云服务器

$serverIP = "116.176.77.165"
$serverUser = "root"
$serverPassword = "147258AA@s"
$localConfigPath = "D:\AI编程\openclaw\.openclaw\openclaw.json"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  OpenClaw 部署到联通云服务器" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 检查是否安装了SSH客户端
if (-not (Get-Command ssh -ErrorAction SilentlyContinue)) {
    Write-Host "错误：未找到SSH客户端，请先安装OpenSSH" -ForegroundColor Red
    exit 1
}

Write-Host "服务器信息：" -ForegroundColor Yellow
Write-Host "  IP地址: $serverIP"
Write-Host "  用户名: $serverUser"
Write-Host ""

# 创建部署命令
$deployCommands = @'
# 检查OpenClaw是否已安装
if command -v openclaw &> /dev/null; then
    echo "OpenClaw已安装"
else
    echo "正在安装OpenClaw..."
    npm install -g openclaw
fi

# 创建配置目录
mkdir -p ~/.openclaw

# 备份现有配置
if [ -f ~/.openclaw/openclaw.json ]; then
    cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.backup
fi

# 开放端口
sudo ufw allow 18789 || sudo iptables -A INPUT -p tcp --dport 18789 -j ACCEPT

# 停止现有进程
pkill -f "openclaw gateway" || true

# 启动网关
nohup openclaw gateway > /var/log/openclaw.log 2>&1 &

echo "OpenClaw网关已启动"
echo "公网地址: http://$serverIP:18789"
'@

Write-Host "部署命令已准备完成" -ForegroundColor Green
Write-Host ""
Write-Host "下一步操作：" -ForegroundColor Yellow
Write-Host "1. 手动SSH连接到服务器：ssh root@116.176.77.165" -ForegroundColor White
Write-Host "2. 密码：147258AA@s" -ForegroundColor White
Write-Host "3. 复制并运行上述部署命令" -ForegroundColor White
Write-Host ""
Write-Host "或者使用以下命令自动部署：" -ForegroundColor Yellow
Write-Host "  ssh root@116.176.77.165 `"$deployCommands`"" -ForegroundColor White
