$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File D:\AI编程\openclaw\scripts\update-openclaw.ps1"
$trigger = New-ScheduledTaskTrigger -Daily -At "20:00"
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopOnIdleEnd -AllowStartIfOnBatteries
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERNAME" -LogonType Interactive -RunLevel Highest
$task = New-ScheduledTask -Action $action -Trigger $trigger -Settings $settings -Principal $principal
Register-ScheduledTask -TaskName "OpenClaw-AutoUpdate" -InputObject $task -Force
Write-Host "Task created: OpenClaw-AutoUpdate"
Write-Host "Schedule: Daily at 20:00"
