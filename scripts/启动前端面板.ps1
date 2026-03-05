# OpenClaw 前端面板启动脚本
# 配置环境变量并启动前端面板服务器

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$baseDir = Split-Path -Parent $scriptPath

# 设置环境变量 - 使用相对路径避免编码问题
$env:OPENCLAW_STATE_DIR = Join-Path $baseDir ".\.openclaw"
$env:OPENCLAW_CONFIG_PATH = Join-Path $baseDir ".\.openclaw\openclaw.json"

Write-Host "========================================" -ForegroundColor Green
Write-Host "  启动 OpenClaw 前端面板" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "  状态目录: $env:OPENCLAW_STATE_DIR" -ForegroundColor Cyan
Write-Host "  配置文件: $env:OPENCLAW_CONFIG_PATH" -ForegroundColor Cyan
Write-Host ""

# 启动前端面板服务器
$panelScript = Join-Path $baseDir "panel\openclaw-panel-server.ps1"

if (Test-Path $panelScript) {
    Write-Host "正在启动前端面板..." -ForegroundColor Yellow
    Start-Process powershell.exe -ArgumentList "-NoExit", "-ExecutionPolicy", "Bypass", "-File", $panelScript -WindowStyle Normal
    
    Start-Sleep -Seconds 2
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  前端面板已启动！" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "  前端地址: http://localhost:38789" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  按 Ctrl+C 停止服务" -ForegroundColor Yellow
    Write-Host ""
    
    # 打开浏览器
    Start-Process "http://localhost:38789"
} else {
    Write-Host "错误: 找不到前端面板脚本" -ForegroundColor Red
    Write-Host "路径: $panelScript" -ForegroundColor Red
}
