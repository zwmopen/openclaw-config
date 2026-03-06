# Create OpenClaw startup sequence scheduled task

$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File 'D:\AI编程\openclaw\scripts\startup-sequence.ps1'"
$trigger = New-ScheduledTaskTrigger -AtLogon
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopOnIdleEnd -AllowStartIfOnBatteries
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest

Register-ScheduledTask -TaskName "OpenClaw-Startup-Sequence" -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Force -Description "OpenClaw startup sequence: Gateway -> CC Switch -> Claude Code"

Write-Host "Task created: OpenClaw-Startup-Sequence" -ForegroundColor Green
Write-Host "Trigger: At logon" -ForegroundColor Cyan
