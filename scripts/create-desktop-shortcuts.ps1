# 创建桌面快捷方式
# 功能：在桌面创建OpenClaw管理快捷方式

$WshShell = New-Object -comObject WScript.Shell
$Desktop = [System.IO.Path]::Combine([Environment]::GetFolderPath("Desktop"))

# 1. 重启Gateway快捷方式
$Shortcut = $WshShell.CreateShortcut("$Desktop\OpenClaw-重启Gateway.lnk")
$Shortcut.TargetPath = "powershell.exe"
$Shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"D:\AICode\openclaw\scripts\restart-gateway-safe.ps1`""
$Shortcut.WorkingDirectory = "D:\AICode\openclaw\scripts"
$Shortcut.Description = "安全重启OpenClaw Gateway"
$Shortcut.Save()
Write-Host "? 已创建：OpenClaw-重启Gateway.lnk" -ForegroundColor Green

# 2. 健康检查快捷方式
$Shortcut = $WshShell.CreateShortcut("$Desktop\OpenClaw-健康检查.lnk")
$Shortcut.TargetPath = "powershell.exe"
$Shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"D:\AICode\openclaw\scripts\check-gateway-health.ps1`""
$Shortcut.WorkingDirectory = "D:\AICode\openclaw\scripts"
$Shortcut.Description = "检查OpenClaw Gateway健康状态"
$Shortcut.Save()
Write-Host "? 已创建：OpenClaw-健康检查.lnk" -ForegroundColor Green

# 3. 查看日志快捷方式
$logDir = "D:\AICode\openclaw\.openclaw\logs"
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

$Shortcut = $WshShell.CreateShortcut("$Desktop\OpenClaw-查看日志.lnk")
$Shortcut.TargetPath = "explorer.exe"
$Shortcut.Arguments = $logDir
$Shortcut.Description = "打开OpenClaw日志目录"
$Shortcut.Save()
Write-Host "? 已创建：OpenClaw-查看日志.lnk" -ForegroundColor Green

Write-Host ""
Write-Host "? 桌面快捷方式创建完成！" -ForegroundColor Cyan
Write-Host "位置：$Desktop" -ForegroundColor Gray


