# 设置屏幕亮度到50%
# 用于早上7:00自动调节亮度

$brightness = 50
$timeout = 30000  # 30秒超时
$LogFile = "D:\AI编程\openclaw\logs\brightness.log"

# 确保日志目录存在
$logDir = Split-Path $LogFile -Parent
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

function Write-Log {
    param($Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $Message"
    Add-Content -Path $LogFile -Value $logEntry
    Write-Output $logEntry
}

try {
    # 获取显示器实例
    $monitor = Get-CimInstance -Namespace root/wmi -ClassName WmiMonitorBrightnessMethods -ErrorAction Stop
    
    if ($monitor) {
        # 设置亮度
        Invoke-CimMethod -InputObject $monitor -MethodName WmiSetBrightness -Arguments @{Brightness = $brightness; Timeout = $timeout}
        Write-Log "✅ 亮度已设置为 $brightness%"
        
        # 发送通知到飞书
        $NotificationScript = "D:\AI编程\openclaw\scripts\Send-Notification.ps1"
        if (Test-Path $NotificationScript) {
            & $NotificationScript -Title "✅ 亮度已调整" -Message "屏幕亮度已自动调节到 50%" -Status "success"
        }
    } else {
        Write-Log "⚠️ 未找到显示器实例"
    }
} catch {
    Write-Log "❌ 设置亮度失败: $_"
}
