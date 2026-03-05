# OpenClaw 云服务器部署脚本
# 部署到联通云服务器 116.176.77.165

param(
    [string]$ServerIP = "116.176.77.165",
    [string]$User = "root",
    [string]$Password = "147258AA@s"
)

Write-Host "========================================" -ForegroundColor Green
Write-Host "  OpenClaw 云服务器部署" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

# 检查SSH连接
Write-Host "`n[1/5] 检查SSH连接..." -ForegroundColor Yellow
$sshTest = ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 "$User@$ServerIP" "echo 'OK'" 2>&1
if ($sshTest -ne "OK") {
    Write-Host "SSH连接失败，请检查服务器状态" -ForegroundColor Red
    exit 1
}
Write-Host "SSH连接成功" -ForegroundColor Green

# 安装Node.js
Write-Host "`n[2/5] 安装Node.js..." -ForegroundColor Yellow
ssh "$User@$ServerIP" @"
    if ! command -v node &> /dev/null; then
        curl -fsSL https://rpm.nodesource.com/setup_22.x | bash -
        yum install -y nodejs
    fi
    node --version
"@

# 安装OpenClaw
Write-Host "`n[3/5] 安装OpenClaw..." -ForegroundColor Yellow
ssh "$User@$ServerIP" @"
    npm install -g openclaw
    npm install -g @larksuiteoapi/node-sdk
    openclaw --version
"@

# 创建配置目录
Write-Host "`n[4/5] 创建配置目录..." -ForegroundColor Yellow
ssh "$User@$ServerIP" @"
    mkdir -p /root/.openclaw
    mkdir -p /root/openclaw-workspace
"@

# 上传配置文件
Write-Host "`n[5/5] 上传配置文件..." -ForegroundColor Yellow
scp "D:\AI编程\openclaw\.openclaw\openclaw.json" "$User@$ServerIP:/root/.openclaw/openclaw.json"

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "  部署完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "  服务器地址: http://$ServerIP:18789" -ForegroundColor Cyan
Write-Host "  SSH连接: ssh $User@$ServerIP" -ForegroundColor Cyan
Write-Host "  密码: $Password" -ForegroundColor Cyan
Write-Host ""
Write-Host "  启动命令: ssh $User@$ServerIP 'openclaw gateway'" -ForegroundColor Yellow
Write-Host ""
