# OpenClaw Gateway 重启脚本
# 停止当前Gateway进程并重新启动

$env:OPENCLAW_STATE_DIR = Join-Path $PSScriptRoot "..\.openclaw"
$env:OPENCLAW_CONFIG_PATH = Join-Path $env:OPENCLAW_STATE_DIR "openclaw.json"

Write-Host "Stopping OpenClaw Gateway..." -ForegroundColor Yellow

# Find and stop Gateway process
$gatewayProcess = Get-Process -Name node -ErrorAction SilentlyContinue | 
    Where-Object { $_.Id -eq (Get-NetTCPConnection -LocalPort 18789 -ErrorAction SilentlyContinue).OwningProcess }

if ($gatewayProcess) {
    Stop-Process -Id $gatewayProcess.Id -Force
    Write-Host "Stopped PID: $($gatewayProcess.Id)" -ForegroundColor Green
    Start-Sleep -Seconds 2
} else {
    Write-Host "No running Gateway found" -ForegroundColor Gray
}

Write-Host "Starting OpenClaw Gateway..." -ForegroundColor Cyan

$nodeExe = "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node.exe"
$openclawMjs = "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node_modules\openclaw\openclaw.mjs"

Start-Process -FilePath $nodeExe -ArgumentList $openclawMjs, "gateway" -WindowStyle Hidden

Write-Host "OpenClaw Gateway restarted" -ForegroundColor Green
Write-Host "Port: 18789" -ForegroundColor Gray
