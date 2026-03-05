# 创建 OpenClaw 桌面快捷方式

$WshShell = New-Object -ComObject WScript.Shell
$Desktop = [System.Environment]::GetFolderPath('Desktop')
$ShortcutPath = Join-Path $Desktop "OpenClaw.lnk"

$Shortcut = $WshShell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = "powershell.exe"
$Shortcut.Arguments = "-ExecutionPolicy Bypass -File `"D:\AI编程\openclaw\start-all.ps1`""
$Shortcut.WorkingDirectory = "D:\AI编程\openclaw"
$Shortcut.Description = "OpenClaw AI Assistant"
$Shortcut.IconLocation = "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node_modules\openclaw\assets\icon.ico,0"
$Shortcut.Save()

Write-Host "桌面快捷方式已创建: $ShortcutPath" -ForegroundColor Green

# 同时创建停止脚本快捷方式
$StopShortcutPath = Join-Path $Desktop "OpenClaw停止.lnk"
$StopShortcut = $WshShell.CreateShortcut($StopShortcutPath)
$StopShortcut.TargetPath = "powershell.exe"
$StopShortcut.Arguments = "-Command `"Get-Process -Name node -ErrorAction SilentlyContinue | Where-Object { `$_.CommandLine -like '*openclaw*' } | Stop-Process -Force; Write-Host 'OpenClaw已停止' -ForegroundColor Green; Start-Sleep -Seconds 2`""
$StopShortcut.WorkingDirectory = "D:\AI编程\openclaw"
$StopShortcut.Description = "停止 OpenClaw"
$StopShortcut.Save()

Write-Host "停止快捷方式已创建: $StopShortcutPath" -ForegroundColor Green
