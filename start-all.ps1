# OpenClaw 一键启动脚本
# 同时启动网关和前端面板

Write-Host "========================================" -ForegroundColor Green
Write-Host "  OpenClaw 一键启动" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# 设置环境变量
$env:OPENCLAW_STATE_DIR = Join-Path $scriptDir ".openclaw"
$env:OPENCLAW_CONFIG_PATH = Join-Path $env:OPENCLAW_STATE_DIR "openclaw.json"

Write-Host "`n[1/2] 启动 OpenClaw 网关..." -ForegroundColor Yellow

# 启动网关
$gatewayJob = Start-Job -ScriptBlock {
    param($nodeExe, $openclawMjs, $stateDir, $configPath)
    $env:OPENCLAW_STATE_DIR = $stateDir
    $env:OPENCLAW_CONFIG_PATH = $configPath
    & $nodeExe $openclawMjs "gateway"
} -ArgumentList @(
    "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node.exe",
    "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node_modules\openclaw\openclaw.mjs",
    $env:OPENCLAW_STATE_DIR,
    $env:OPENCLAW_CONFIG_PATH
)

Start-Sleep -Seconds 3

Write-Host "[2/2] 启动前端面板..." -ForegroundColor Yellow

# 启动前端面板
$panelScript = Join-Path $scriptDir "panel\openclaw-panel-server.ps1"
$panelJob = Start-Job -ScriptBlock {
    param($powershell, $script)
    & $powershell -ExecutionPolicy Bypass -File $script
} -ArgumentList @("powershell", $panelScript)

Start-Sleep -Seconds 2

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "  启动完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "  网关地址: http://127.0.0.1:18789" -ForegroundColor Cyan
Write-Host "  前端面板: http://localhost:38789" -ForegroundColor Cyan
Write-Host ""
Write-Host "  按 Ctrl+C 停止所有服务" -ForegroundColor Yellow
Write-Host ""

# 打开浏览器
Start-Process "http://localhost:38789"

# 等待用户中断
try {
    while ($true) {
        Receive-Job -Job $gatewayJob -ErrorAction SilentlyContinue
        Receive-Job -Job $panelJob -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
    }
} finally {
    Write-Host "`n正在停止服务..." -ForegroundColor Yellow
    Stop-Job -Job $gatewayJob -ErrorAction SilentlyContinue
    Stop-Job -Job $panelJob -ErrorAction SilentlyContinue
    Remove-Job -Job $gatewayJob -ErrorAction SilentlyContinue
    Remove-Job -Job $panelJob -ErrorAction SilentlyContinue
    Write-Host "服务已停止" -ForegroundColor Green
}
