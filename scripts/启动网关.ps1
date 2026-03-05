# OpenClaw 网关启动脚本
# 配置环境变量并启动网关

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$baseDir = Split-Path -Parent $scriptPath

# 设置环境变量
$env:OPENCLAW_STATE_DIR = Join-Path $baseDir ".\.openclaw"
$env:OPENCLAW_CONFIG_PATH = Join-Path $baseDir ".\.openclaw\openclaw.json"

Write-Host "========================================" -ForegroundColor Green
Write-Host "  启动 OpenClaw 网关" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "  状态目录: $env:OPENCLAW_STATE_DIR" -ForegroundColor Cyan
Write-Host "  配置文件: $env:OPENCLAW_CONFIG_PATH" -ForegroundColor Cyan
Write-Host ""

# Node.js 路径
$nodeExe = "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node.exe"
$openclawMjs = "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node_modules\openclaw\openclaw.mjs"

Write-Host "正在启动网关..." -ForegroundColor Yellow
Write-Host ""

& $nodeExe $openclawMjs gateway
