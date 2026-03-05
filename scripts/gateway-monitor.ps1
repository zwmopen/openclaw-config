# OpenClaw 网关状态监控脚本
# 检测网关是否在线，状态变化时发送飞书通知

$gatewayUrl = "http://127.0.0.1:18789"
$stateFile = "D:\AI编程\openclaw\.openclaw\gateway-state.json"
$logFile = "D:\AI编程\openclaw\.openclaw\gateway-monitor.log"

# 飞书配置
$feishuAppId = "cli_a92b975b47781bca"
$feishuAppSecret = "E6prhpRy7rsrVa7lMwpnHeNwbmsxkTCs"
$feishuUserId = "ou_87628a02a45ec6d7205b79cda92b20f7"

function Write-Log {
    param($message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "[$timestamp] $message" | Out-File -FilePath $logFile -Append -Encoding UTF8
}

function Get-GatewayStatus {
    try {
        $response = Invoke-WebRequest -Uri "$gatewayUrl/health" -TimeoutSec 5 -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

function Get-FeishuToken {
    $url = "https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal"
    $body = @{
        app_id = $feishuAppId
        app_secret = $feishuAppSecret
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType "application/json"
    return $response.tenant_access_token
}

function Send-FeishuMessage {
    param($message)
    
    try {
        $token = Get-FeishuToken
        $url = "https://open.feishu.cn/open-apis/im/v1/messages?receive_id_type=user_id"
        $headers = @{
            "Authorization" = "Bearer $token"
            "Content-Type" = "application/json"
        }
        $body = @{
            receive_id = $feishuUserId
            msg_type = "text"
            content = "{`"text`":`"$message`"}"
        } | ConvertTo-Json -Depth 10
        
        Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body -ContentType "application/json" | Out-Null
        Write-Log "Message sent: $message"
    } catch {
        Write-Log "Failed to send message: $_"
    }
}

# 主逻辑
$currentStatus = Get-GatewayStatus
$previousStatus = $null

# 读取上次状态
if (Test-Path $stateFile) {
    $state = Get-Content $stateFile | ConvertFrom-Json
    $previousStatus = $state.online
}

# 记录当前状态
@{
    online = $currentStatus
    lastCheck = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
} | ConvertTo-Json | Out-File $stateFile -Encoding UTF8

# 状态变化检测
if ($null -ne $previousStatus -and $previousStatus -ne $currentStatus) {
    if ($currentStatus) {
        Write-Log "Gateway ONLINE (was offline)"
        Send-FeishuMessage "🔄 OpenClaw 网关已重新上线！"
    } else {
        Write-Log "Gateway OFFLINE (was online)"
        Send-FeishuMessage "⚠️ OpenClaw 网关已断线！"
    }
} else {
    Write-Log "Gateway status: $(if($currentStatus){'ONLINE'}else{'OFFLINE'})"
}
