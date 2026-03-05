# 设置屏幕亮度到50%
# 用于早上7:30自动调节亮度

$brightness = 50
$timeout = 30000  # 30秒超时

try {
    # 获取显示器实例
    $monitor = Get-CimInstance -Namespace root/wmi -ClassName WmiMonitorBrightnessMethods -ErrorAction Stop
    
    if ($monitor) {
        # 设置亮度
        Invoke-CimMethod -InputObject $monitor -MethodName WmiSetBrightness -Arguments @{Brightness = $brightness; Timeout = $timeout}
        Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] 亮度已设置为 $brightness%"
    } else {
        Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] 未找到显示器实例"
    }
} catch {
    Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] 设置亮度失败: $_"
}
