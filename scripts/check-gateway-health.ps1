# OpenClaw Gateway 健康检查脚本
# 功能：检查Gateway是否正常，如果不正常则自动重启

$env:OPENCLAW_STATE_DIR = Join-Path $PSScriptRoot "..\.openclaw"
$logDir = Join-Path $env:OPENCLAW_STATE_DIR "logs"
$logFile = Join-Path $logDir "health-check.log"

# 创建日志目录
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

function Write-Log {
    param([string]$message, [string]$color = "White")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $message"
    Write-Host $logMessage -ForegroundColor $color
    Add-Content -Path $logFile -Value $logMessage
}

# 检查端口18789
$port18789 = Get-NetTCPConnection -LocalPort 18789 -ErrorAction SilentlyContinue

if ($port18789) {
    $process = Get-Process -Id $port18789.OwningProcess -ErrorAction SilentlyContinue
    if ($process) {
        Write-Log "✅ Gateway 正常运行 (PID: $($process.Id), 内存: $([math]::Round($process.WorkingSet64 / 1MB, 1))MB)" "Green"
        exit 0
    } else {
        Write-Log "❌ 端口被占用但进程不存在，尝试重启..." "Yellow"
        & "$PSScriptRoot\restart-gateway-safe.ps1"
        exit 1
    }
} else {
    Write-Log "❌ Gateway 未运行，尝试重启..." "Yellow"
    & "$PSScriptRoot\restart-gateway-safe.ps1"
    exit 1
}
