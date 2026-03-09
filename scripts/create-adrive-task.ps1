# 创建阿里云盘定时任务（周日9点）
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File 'D:\AICode\openclaw\scripts\open-adrive.ps1'"
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 9am
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopOnIdleEnd
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest

Register-ScheduledTask -TaskName "OpenClaw_OpenADrive" -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Force

Write-Host "? 定时任务已创建：每周日 09:00 打开阿里云盘" -ForegroundColor Green


