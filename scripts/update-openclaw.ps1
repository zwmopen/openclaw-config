# OpenClaw 自动更新脚本
# 每天晚上8点运行

Write-Host "=== OpenClaw 自动更新检测 ===" -ForegroundColor Cyan
Write-Host "时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray

# 切换到 OpenClaw 目录
Set-Location "D:\openclaw"

# 检查是否有更新
Write-Host "`n检查更新..." -ForegroundColor Yellow

# 记录当前版本
$currentVersion = npm list openclaw --global 2>&1 | Select-String "openclaw@"
Write-Host "当前版本: $currentVersion" -ForegroundColor Gray

# 更新 OpenClaw
Write-Host "`n正在更新..." -ForegroundColor Yellow
npm update -g openclaw 2>&1

# 检查更新后的版本
$newVersion = npm list openclaw --global 2>&1 | Select-String "openclaw@"
Write-Host "更新后版本: $newVersion" -ForegroundColor Green

# 检查 Gateway 是否运行
Write-Host "`n检查 Gateway 状态..." -ForegroundColor Yellow
$gateway = Get-Process -Name "node" -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -match "gateway" -or $_.CommandLine -match "gateway" }

if ($gateway) {
    Write-Host "Gateway 正在运行" -ForegroundColor Green
} else {
    Write-Host "Gateway 未运行，尝试启动..." -ForegroundColor Yellow
    Start-Process -FilePath "npx" -ArgumentList "openclaw", "gateway" -WindowStyle Hidden
    Write-Host "Gateway 已启动" -ForegroundColor Green
}

Write-Host "`n=== 更新检测完成 ===" -ForegroundColor Cyan

# 记录日志
$logPath = "D:\openclaw\.openclaw\update-log.txt"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"$timestamp - 更新检测完成" | Out-File -FilePath $logPath -Append

