# 特定时间提醒脚本
# 在指定时间发送飞书消息提醒

param(
    [string]$Message = "⏰ 提醒：找美妆、摄影对标"
)

$ErrorActionPreference = "SilentlyContinue"

# 记录日志
$logFile = "D:\openclaw\logs\reminder.log"
$logDir = Split-Path $logFile -Parent
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content -Path $logFile -Value "[$timestamp] 执行提醒: $Message"

# 发送到飞书（通过 OpenClaw Gateway API）
$gatewayUrl = "http://127.0.0.1:18789"
$token = "2d65353ea3422e1bd863c865f7cc9b3d92514be0fd19ebd8"

# 检查 Gateway 是否运行
try {
    $health = Invoke-RestMethod -Uri "$gatewayUrl/health" -Method Get -TimeoutSec 5
} catch {
    Add-Content -Path $logFile -Value "[$timestamp] Gateway 未运行"
    Write-Host "Gateway 未运行"
    exit 0
}

# 通过 sessions_send 发送消息
try {
    $body = @{
        message = $Message
        sessionKey = "agent:main:main"
    } | ConvertTo-Json

    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }

    $response = Invoke-RestMethod -Uri "$gatewayUrl/api/sessions/send" -Method Post -Body $body -Headers $headers -TimeoutSec 10
    Add-Content -Path $logFile -Value "[$timestamp] 消息发送成功"
    Write-Host "✅ 提醒已发送"
} catch {
    Add-Content -Path $logFile -Value "[$timestamp] 发送失败: $_"
    Write-Host "❌ 发送失败: $_"
}

