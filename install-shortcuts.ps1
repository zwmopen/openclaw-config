# Create OpenClaw Desktop Shortcut and Startup Entry

$WshShell = New-Object -ComObject WScript.Shell
$scriptDir = "D:\AI编程\openclaw"

# Desktop Shortcut
$desktopPath = [System.Environment]::GetFolderPath("Desktop")
$shortcutPath = Join-Path $desktopPath "OpenClaw.lnk"

$shortcut = $WshShell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = "powershell.exe"
$shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$scriptDir\start-all.ps1`""
$shortcut.WorkingDirectory = $scriptDir
$shortcut.Description = "OpenClaw One-Click Start"
$shortcut.Save()

Write-Host "Desktop shortcut created: $shortcutPath" -ForegroundColor Green

# Startup Entry
$startupPath = [System.Environment]::GetFolderPath("Startup")
$startupShortcutPath = Join-Path $startupPath "OpenClaw-Gateway.lnk"

$startupShortcut = $WshShell.CreateShortcut($startupShortcutPath)
$startupShortcut.TargetPath = "powershell.exe"
$startupShortcut.Arguments = "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptDir\start-gateway-silent.ps1`""
$startupShortcut.WorkingDirectory = $scriptDir
$startupShortcut.Description = "OpenClaw Gateway Auto-Start"
$startupShortcut.Save()

Write-Host "Startup entry created: $startupShortcutPath" -ForegroundColor Green
Write-Host ""
Write-Host "Done! OpenClaw will auto-start on boot." -ForegroundColor Cyan
