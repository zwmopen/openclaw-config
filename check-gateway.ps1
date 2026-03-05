# OpenClaw Gateway 自检脚本
# 每12小时检查一次，如果停止则重启

$port = 18789
$nodePath = "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node.exe"
$openclawPath = "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node_modules\openclaw\openclaw.mjs"
$scriptDir = "D:\AI编程\openclaw"
$logFile = Join-Path $scriptDir "gateway-check.log"

function Write-Log {
    param($message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Add-Content -Path $logFile
}

# 检查端口是否被监听
$gatewayRunning = netstat -ano | Select-String ":$port.*LISTENING"

if ($gatewayRunning) {
    Write-Log "Gateway 正常运行中 (端口 $port)"
    exit 0
}

Write-Log "Gateway 未运行，正在重启..."

# 设置环境变量
$env:OPENCLAW_STATE_DIR = Join-Path $scriptDir ".openclaw"
$env:OPENCLAW_CONFIG_PATH = Join-Path $env:OPENCLAW_STATE_DIR "openclaw.json"

# 启动 Gateway
Start-Process -FilePath $nodePath `
    -ArgumentList $openclawPath, "gateway" `
    -WindowStyle Hidden `
    -Environment @{
        OPENCLAW_STATE_DIR = $env:OPENCLAW_STATE_DIR
        OPENCLAW_CONFIG_PATH = $env:OPENCLAW_CONFIG_PATH
    }

# 等待3秒后检查
Start-Sleep -Seconds 3

$gatewayRunning = netstat -ano | Select-String ":$port.*LISTENING"
if ($gatewayRunning) {
    Write-Log "Gateway 重启成功"
    exit 0
} else {
    Write-Log "Gateway 重启失败，请检查日志"
    exit 1
}
