# OpenClaw 启动脚本
# 设置环境变量并启动网关

$env:OPENCLAW_STATE_DIR = Join-Path $PSScriptRoot "..\.openclaw"
$env:OPENCLAW_CONFIG_PATH = Join-Path $env:OPENCLAW_STATE_DIR "openclaw.json"

Write-Host "Starting OpenClaw Gateway..." -ForegroundColor Cyan
Write-Host "State Dir: $env:OPENCLAW_STATE_DIR" -ForegroundColor Gray
Write-Host "Config: $env:OPENCLAW_CONFIG_PATH" -ForegroundColor Gray

$nodeExe = "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node.exe"
$openclawMjs = "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node_modules\openclaw\openclaw.mjs"

& $nodeExe $openclawMjs gateway
