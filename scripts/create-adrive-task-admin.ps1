# 一键创建阿里云盘定时任务（周日9点）
# 需要以管理员身份运行

Write-Host "创建阿里云盘定时任务..." -ForegroundColor Yellow

# 删除旧任务（如果存在）
schtasks /delete /tn "OpenClaw_OpenADrive" /f 2>$null

# 创建新任务
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File 'D:\AI编程\openclaw\scripts\open-adrive.ps1'"
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 9am
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopOnIdleEnd
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest

Register-ScheduledTask -TaskName "OpenClaw_OpenADrive" -Action $action -Trigger $trigger -Settings $settings -Principal $Principal -Force

Write-Host "✅ 定时任务已创建：每周日 09:00 打开阿里云盘" -ForegroundColor Green
Write-Host ""
Write-Host "验证任务："
schtasks /query /tn "OpenClaw_OpenADrive" /fo LIST /v | Select-String "TaskName","Next Run Time","Status"

Read-Host "按回车键退出"
