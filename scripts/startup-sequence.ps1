# OpenClaw启动顺序脚本
# 开机自动运行：OpenClaw → CC Switch → Claude Code

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "OpenClaw启动顺序" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. 检查OpenClaw Gateway
Write-Host "[1/3] 检查OpenClaw Gateway..." -ForegroundColor Yellow
$gateway = Test-NetConnection -ComputerName 127.0.0.1 -Port 18789 -InformationLevel Quiet
if ($gateway) {
    Write-Host "✅ OpenClaw Gateway运行中（端口18789）" -ForegroundColor Green
} else {
    Write-Host "❌ OpenClaw Gateway未运行，正在启动..." -ForegroundColor Red
    Start-Process "openclaw" -ArgumentList "gateway start" -WindowStyle Hidden
    Start-Sleep -Seconds 5
}

# 2. 启动CC Switch
Write-Host "[2/3] 检查CC Switch..." -ForegroundColor Yellow
$ccswitch = Test-NetConnection -ComputerName 127.0.0.1 -Port 15721 -InformationLevel Quiet
if ($ccswitch) {
    Write-Host "✅ CC Switch代理服务器运行中（端口15721）" -ForegroundColor Green
} else {
    Write-Host "❌ CC Switch未运行，正在启动..." -ForegroundColor Red
    Invoke-Item "C:\Users\z\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\CC Switch\CC Switch.lnk"
    Start-Sleep -Seconds 5
    
    # 等待代理服务器启动
    $retry = 0
    while (-not (Test-NetConnection -ComputerName 127.0.0.1 -Port 15721 -InformationLevel Quiet) -and $retry -lt 10) {
        Start-Sleep -Seconds 1
        $retry++
    }
    
    if (Test-NetConnection -ComputerName 127.0.0.1 -Port 15721 -InformationLevel Quiet) {
        Write-Host "✅ CC Switch代理服务器已启动" -ForegroundColor Green
    } else {
        Write-Host "❌ CC Switch代理服务器启动失败" -ForegroundColor Red
    }
}

# 3. 切换CC Switch配置
Write-Host "[3/3] 切换CC Switch配置..." -ForegroundColor Yellow
cc-switch unicom-new 2>$null
Write-Host "✅ CC Switch配置已切换到 unicom-new" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "启动完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "端口状态：" -ForegroundColor Cyan
Write-Host "  OpenClaw Gateway: 18789" -ForegroundColor Gray
Write-Host "  CC Switch Proxy:  15721" -ForegroundColor Gray
Write-Host ""
Write-Host "使用方法：" -ForegroundColor Cyan
Write-Host "  claude           # 启动Claude Code" -ForegroundColor Gray
Write-Host "  cc-switch --list # 查看配置列表" -ForegroundColor Gray
Write-Host ""
