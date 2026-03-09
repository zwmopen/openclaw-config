# 创建桌面快捷方式

$WshShell = New-Object -ComObject WScript.Shell

# 创建"启动 Gateway"快捷方式
$shortcutPath = "$env:USERPROFILE\Desktop\启动Gateway.lnk"
$shortcut = $WshShell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = "D:\AI编程\openclaw\启动Gateway.bat"
$shortcut.WorkingDirectory = "D:\AI编程\openclaw"
$shortcut.Description = "启动 OpenClaw Gateway"
$shortcut.Save()

Write-Host "✅ 已创建桌面快捷方式: 启动Gateway.lnk" -ForegroundColor Green

# 创建"重启 Gateway"快捷方式
$shortcutPath = "$env:USERPROFILE\Desktop\重启Gateway.lnk"
$shortcut = $WshShell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = "D:\AI编程\openclaw\重启Gateway.bat"
$shortcut.WorkingDirectory = "D:\AI编程\openclaw"
$shortcut.Description = "重启 OpenClaw Gateway"
$shortcut.Save()

Write-Host "✅ 已创建桌面快捷方式: 重启Gateway.lnk" -ForegroundColor Green

# 创建开机自启动快捷方式（更新）
$startupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
$shortcutPath = Join-Path $startupPath "OpenClaw-Gateway.lnk"
$shortcut = $WshShell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = "D:\AI编程\openclaw\启动Gateway.bat"
$shortcut.WorkingDirectory = "D:\AI编程\openclaw"
$shortcut.Description = "开机自动启动 OpenClaw Gateway"
$shortcut.Save()

Write-Host "✅ 已更新开机自启动快捷方式" -ForegroundColor Green

Write-Host ""
Write-Host "完成！" -ForegroundColor Cyan
Write-Host ""
Write-Host "桌面快捷方式：" -ForegroundColor Cyan
Write-Host "  - 启动Gateway.lnk" -ForegroundColor Gray
Write-Host "  - 重启Gateway.lnk" -ForegroundColor Gray
Write-Host ""
Write-Host "开机自启动：" -ForegroundColor Cyan
Write-Host "  - Startup\OpenClaw-Gateway.lnk" -ForegroundColor Gray
