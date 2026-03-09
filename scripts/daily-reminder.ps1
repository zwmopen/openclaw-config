# 每日任务提醒脚本
# 通过飞书发送任务提醒

param(
    [switch]$Test
)

$ErrorActionPreference = "SilentlyContinue"

# 获取当前时间
$now = Get-Date
$hour = $now.Hour

# 任务列表（根据时间显示不同任务）
$tasks = @(
    "找美妆（10:00）",
    "摄影对标（10:00）",
    "清理滴答清单",
    "洗澡",
    "写一份简历"
)

# 构建消息
$message = @"
☀️ 早安大哥！今天的任务：

⏰ 10:00 重要：
1. 找美妆
2. 摄影对标

日常待办：
3. 清理滴答清单
4. 洗澡
5. 写一份简历

记得完成哦！💪
"@

# 如果是测试模式，直接输出消息
if ($Test) {
    Write-Host $message
    exit 0
}

# 记录日志
$logFile = "D:\openclaw\logs\reminder.log"
$logDir = Split-Path $logFile -Parent
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content -Path $logFile -Value "[$timestamp] 执行任务提醒"

# 发送到飞书（通过 OpenClaw Gateway API）
$gatewayUrl = "http://127.0.0.1:18789"
$token = "2d65353ea3422e1bd863c865f7cc9b3d92514be0fd19ebd8"

# 检查 Gateway 是否运行
try {
    $health = Invoke-RestMethod -Uri "$gatewayUrl/health" -Method Get -TimeoutSec 5
    Write-Host "Gateway 运行中"
} catch {
    Write-Host "Gateway 未运行，跳过发送"
    Add-Content -Path $logFile -Value "[$timestamp] Gateway 未运行"
    exit 0
}

# 通过 sessions_send 发送消息
try {
    $body = @{
        message = $message
        sessionKey = "agent:main:main"
    } | ConvertTo-Json -Encoding UTF8

    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json; charset=utf-8"
    }

    $response = Invoke-RestMethod -Uri "$gatewayUrl/api/sessions/send" -Method Post -Body ([System.Text.Encoding]::UTF8.GetBytes($body)) -Headers $headers -TimeoutSec 10
    Add-Content -Path $logFile -Value "[$timestamp] 消息发送成功"
    Write-Host "✅ 任务提醒已发送"
} catch {
    Add-Content -Path $logFile -Value "[$timestamp] 发送失败: $_"
    Write-Host "❌ 发送失败: $_"
}

