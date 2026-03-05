# 重启 OpenClaw Gateway 提醒
# 创建时间: 2026-03-04

$reminderTime = Get-Date -Hour 12 -Minute 0 -Second 0
$now = Get-Date

if ($reminderTime -gt $now) {
    $delay = $reminderTime - $now
    $delaySeconds = [int]$delay.TotalSeconds
    
    Write-Host "将在 $delaySeconds 秒后（中午12:00）提醒重启 OpenClaw Gateway"
    
    Start-Sleep -Seconds $delaySeconds
    
    # 发送飞书消息提醒
    Write-Host "⏰ 提醒：请重启 OpenClaw Gateway 使 free-search 技能生效！"
    Write-Host "命令: openclaw gateway restart"
} else {
    Write-Host "提醒时间已过"
}
