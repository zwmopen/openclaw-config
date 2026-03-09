# 发送通知到飞书
# 用于定时任务执行完成后通知用户

param(
    [string]$Title = "OpenClaw 定时任务通知",
    [string]$Message = "任务已完成",
    [string]$Status = "success"  # success, error, warning, info
)

# 飞书 Webhook URL（需要配置）
$WebhookUrl = "YOUR_FEISHU_WEBHOOK_URL"

# 构建消息体
$Body = @{
    msg_type = "interactive"
    card = @{
        header = @{
            title = @{
                tag = "plain_text"
                content = $Title
            }
            template = if ($Status -eq "success") { "green" } elseif ($Status -eq "error") { "red" } elseif ($Status -eq "warning") { "yellow" } else { "blue" }
        }
        elements = @(
            @{
                tag = "div"
                text = @{
                    tag = "plain_text"
                    content = $Message
                }
            }
        )
    }
} | ConvertTo-Json -Depth 10

# 发送通知
try {
    $Response = Invoke-RestMethod -Uri $WebhookUrl -Method Post -Body $Body -ContentType "application/json"
    Write-Log "通知发送成功：$Title - $Message"
    return $Response
}
catch {
    Write-Log "通知发送失败：$_" -Level "ERROR"
    return $null
}

# 写入日志
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Level] $Message"
    
    # 写入日志文件
    $LogFile = "D:\AICode\openclaw\logs\notifications.log"
    $LogMessage | Out-File -FilePath $LogFile -Append -Encoding UTF8
    
    # 输出到控制台
    Write-Host $LogMessage
}
