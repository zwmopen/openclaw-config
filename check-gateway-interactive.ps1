# OpenClaw Gateway 状态检查脚本

param(
    [switch]$NoTimeout = $false
)

function Test-Gateway {
    try {
        $response = Invoke-WebRequest -Uri "http://127.0.0.1:18789/health" -TimeoutSec 2 -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "OpenClaw Gateway 状态检查" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查端口
$port = Get-NetTCPConnection -LocalPort 18789 -ErrorAction SilentlyContinue

if ($port) {
    $process = Get-Process -Id $port.OwningProcess -ErrorAction SilentlyContinue
    $memory = [math]::Round($process.WorkingSet64 / 1MB, 1)
    
    Write-Host "状态:    运行中" -ForegroundColor Green
    Write-Host "端口:    18789 (监听中)" -ForegroundColor Green
    Write-Host "PID:     $($port.OwningProcess)" -ForegroundColor Gray
    Write-Host "内存:    ${memory} MB" -ForegroundColor Gray
    
    # 健康检查
    if (Test-Gateway) {
        Write-Host "健康:    正常" -ForegroundColor Green
    } else {
        Write-Host "健康:    异常（端口开放但健康检查失败）" -ForegroundColor Yellow
    }
} else {
    Write-Host "状态:    未运行" -ForegroundColor Red
    Write-Host "端口:    18789 (未监听)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Gateway 未运行！" -ForegroundColor Yellow
    Write-Host "双击桌面上的 '启动Gateway.lnk' 启动" -ForegroundColor Yellow
}

Write-Host ""

if (-not $NoTimeout) {
    Write-Host "窗口将在 11 分钟后自动关闭，或按任意键立即关闭..." -ForegroundColor DarkGray
    $timeout = 660
    $start = Get-Date
    while (((Get-Date) - $start).TotalSeconds -lt $timeout) {
        if ([Console]::KeyAvailable) {
            [Console]::ReadKey($true) | Out-Null
            exit 0
        }
        Start-Sleep -Milliseconds 100
    }
} else {
    Write-Host "按任意键关闭窗口..." -ForegroundColor DarkGray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
