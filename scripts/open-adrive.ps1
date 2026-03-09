# 自动打开阿里云盘进行同步
# 每周周日 09:00 执行，打开后自动同步
# 注意：打开后不用关闭，让它自动同步，一周的备份可能需要一天

Write-Host "正在打开阿里云盘..." -ForegroundColor Green

# 打开阿里云盘（桌面快捷方式）
$shortcutPath = "$env:USERPROFILE\Desktop\阿里云盘.lnk"

if (Test-Path $shortcutPath) {
    Start-Process $shortcutPath
    Write-Host "? 阿里云盘已打开，开始自动同步" -ForegroundColor Green
    Write-Host "?? 一周的备份可能需要一天时间，保持打开状态" -ForegroundColor Yellow
} else {
    Write-Host "? 未找到阿里云盘快捷方式，请手动打开" -ForegroundColor Red
}

# 记录日志
$logPath = "D:\AICode\openclaw\logs\adrive-sync.log"
$logDir = Split-Path $logPath -Parent
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"$timestamp - 阿里云盘已打开，开始自动同步" | Out-File $logPath -Append

Write-Host "日志已记录: $logPath" -ForegroundColor Gray


