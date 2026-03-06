# OpenClaw Gateway Keep-Alive Script
# Check gateway status every 5 minutes, restart if needed, send notification on status change

param(
    [switch]$Install  # Install as scheduled task
)

$gatewayUrl = "http://127.0.0.1:18789"
$stateFile = "D:\AI编程\openclaw\.openclaw\gateway-state.json"
$logFile = "D:\AI编程\openclaw\.openclaw\keepalive.log"
$nodeExe = "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node.exe"
$openclawMjs = "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node_modules\openclaw\openclaw.mjs"
$stateDir = "D:\AI编程\openclaw\.openclaw"
$configPath = "D:\AI编程\openclaw\.openclaw\openclaw.json"

# Feishu config
$feishuAppId = "cli_a92b975b47781bca"
$feishuAppSecret = "E6prhpRy7rsrVa7lMwpnHeNwbmsxkTCs"
$feishuUserId = "ou_87628a02a45ec6d7205b79cda92b20f7"

function Write-Log {
    param($message, $level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "[$timestamp][$level] $message" | Out-File -FilePath $logFile -Append -Encoding UTF8
    Write-Host "[$timestamp][$level] $message"
}

function Get-GatewayStatus {
    try {
        $response = Invoke-WebRequest -Uri "$gatewayUrl/health" -TimeoutSec 5 -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

function Start-Gateway {
    Write-Log "Starting OpenClaw Gateway..." "WARN"
    
    $env:OPENCLAW_STATE_DIR = $stateDir
    $env:OPENCLAW_CONFIG_PATH = $configPath
    
    Start-Process -FilePath $nodeExe -ArgumentList $openclawMjs, "gateway" -WindowStyle Hidden
    
    Start-Sleep -Seconds 5
    
    $status = Get-GatewayStatus
    if ($status) {
        Write-Log "Gateway started successfully" "INFO"
        return $true
    } else {
        Write-Log "Failed to start gateway" "ERROR"
        return $false
    }
}

function Get-FeishuToken {
    try {
        $url = "https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal"
        $body = @{
            app_id = $feishuAppId
            app_secret = $feishuAppSecret
        } | ConvertTo-Json
        
        $response = Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType "application/json" -TimeoutSec 10
        return $response.tenant_access_token
    } catch {
        Write-Log "Failed to get Feishu token: $_" "ERROR"
        return $null
    }
}

function Send-FeishuMessage {
    param($message)
    
    try {
        $token = Get-FeishuToken
        if (-not $token) {
            Write-Log "No Feishu token, skip notification" "WARN"
            return
        }
        
        $url = "https://open.feishu.cn/open-apis/im/v1/messages?receive_id_type=user_id"
        $headers = @{
            "Authorization" = "Bearer $token"
            "Content-Type" = "application/json"
        }
        $body = @{
            receive_id = $feishuUserId
            msg_type = "text"
            content = '{"text":"' + $message + '"}'
        } | ConvertTo-Json -Depth 10
        
        Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body -ContentType "application/json" -TimeoutSec 10 | Out-Null
        Write-Log "Notification sent: $message" "INFO"
    } catch {
        Write-Log "Failed to send notification: $_" "ERROR"
    }
}

function Install-KeepAliveTask {
    Write-Log "Installing keep-alive scheduled task..." "INFO"
    
    $taskName = "OpenClaw-Gateway-KeepAlive"
    $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    
    if ($existingTask) {
        Write-Log "Task exists, updating..." "WARN"
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
    }
    
    $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 5)
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`"" -WorkingDirectory (Split-Path $PSCommandPath)
    $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopOnIdleEnd -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -RunOnlyIfNetworkAvailable:$false
    $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited
    
    Register-ScheduledTask -TaskName $taskName -Trigger $trigger -Action $action -Settings $settings -Principal $principal -Description "OpenClaw Gateway Keep-Alive (check every 5 minutes)" | Out-Null
    
    Write-Log "Keep-alive task installed" "INFO"
    Send-FeishuMessage "✅ OpenClaw 存活保障已安装`n`n检查间隔：每 5 分钟`n自动重启：启用`n状态通知：启用"
}

# Main logic
if ($Install) {
    Install-KeepAliveTask
    exit 0
}

# Check gateway
$currentStatus = Get-GatewayStatus
$previousStatus = $null
$previousStartTime = $null

# Read previous state
if (Test-Path $stateFile) {
    $state = Get-Content $stateFile | ConvertFrom-Json
    $previousStatus = $state.online
    $previousStartTime = $state.startTime
}

# Update state
$startTime = $previousStartTime
if ($currentStatus -and -not $previousStatus) {
    # Just came online, record start time
    $startTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
}

@{
    online = $currentStatus
    lastCheck = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    startTime = $startTime
} | ConvertTo-Json | Out-File $stateFile -Encoding UTF8

# Status change detection
if ($null -ne $previousStatus -and $previousStatus -ne $currentStatus) {
    if ($currentStatus) {
        Write-Log "Gateway ONLINE (was offline)" "INFO"
        Send-FeishuMessage "✅ OpenClaw 网关已重新上线！`n`n启动时间：$startTime`n检查间隔：每 5 分钟"
    } else {
        Write-Log "Gateway OFFLINE (was online)" "WARN"
        Send-FeishuMessage "⚠️ OpenClaw 网关已断线！`n`n正在尝试重启..."
    }
}

# Auto-restart if offline
if (-not $currentStatus) {
    Write-Log "Gateway offline, attempting restart..." "WARN"
    $success = Start-Gateway
    
    if ($success) {
        $startTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        @{
            online = $true
            lastCheck = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            startTime = $startTime
        } | ConvertTo-Json | Out-File $stateFile -Encoding UTF8
        
        Send-FeishuMessage "✅ OpenClaw 网关已自动重启成功！`n`n启动时间：$startTime"
    } else {
        Send-FeishuMessage "❌ OpenClaw 网关自动重启失败！`n`n请手动检查。"
    }
} else {
    Write-Log "Gateway online" "INFO"
}