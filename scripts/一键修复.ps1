# 一键修复所有定时任务（管理员权限）
# 右键以管理员身份运行

Write-Host "正在修复定时任务..." -ForegroundColor Cyan

# 删除废弃任务
schtasks /delete /tn "\OpenClaw-Gateway-Check" /f 2>$null
schtasks /delete /tn "\OpenClaw_Restart_Reminder" /f 2>$null
schtasks /delete /tn "\OpenClaw-Gateway-AutoStart" /f 2>$null
schtasks /delete /tn "\OpenClaw_OpenADrive" /f 2>$null

# 创建新任务（带 -WindowStyle Hidden）
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File 'D:\AICode\openclaw\scripts\OpenClaw.ps1' -NoTimeout"
$trigger = New-ScheduledTaskTrigger -AtLogon
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopOnIdleEnd -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest
Register-ScheduledTask -TaskName "\OpenClaw-Gateway-AutoStart" -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description "开机自动启动 OpenClaw Gateway" -Force | Out-Null

$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File 'D:\AICode\openclaw\scripts\open-adrive.ps1'"
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 9:00AM
Register-ScheduledTask -TaskName "\OpenClaw_OpenADrive" -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description "每周日 09:00 自动打开阿里云盘同步" -Force | Out-Null

Write-Host "? 修复完成！" -ForegroundColor Green
Write-Host ""
Write-Host "已删除：" -ForegroundColor Yellow
Write-Host "  - OpenClaw-Gateway-Check" -ForegroundColor Gray
Write-Host "  - OpenClaw_Restart_Reminder" -ForegroundColor Gray
Write-Host ""
Write-Host "已修复：" -ForegroundColor Yellow
Write-Host "  - OpenClaw-Gateway-AutoStart（指向新脚本）" -ForegroundColor Gray
Write-Host "  - OpenClaw_OpenADrive（添加 -WindowStyle Hidden）" -ForegroundColor Gray
Write-Host ""
Write-Host "按任意键关闭..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")


