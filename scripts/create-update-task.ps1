# 创建 Windows 任务计划程序任务
# 每天晚上8点自动更新 OpenClaw

$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File `"D:\AICode\openclaw\scripts\update-openclaw.ps1`""

$trigger = New-ScheduledTaskTrigger -Daily -At "20:00"

$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopOnIdleEnd -AllowStartIfOnBatteries

$principal = New-ScheduledTaskPrincipal -UserId "$env:USERNAME" -LogonType Interactive -RunLevel Highest

$task = New-ScheduledTask -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description "每天晚上8点自动检测并更新 OpenClaw"

# 注册任务
Register-ScheduledTask -TaskName "OpenClaw-AutoUpdate" -InputObject $task -Force

Write-Host "任务创建成功！" -ForegroundColor Green
Write-Host "任务名称: OpenClaw-AutoUpdate" -ForegroundColor Cyan
Write-Host "执行时间: 每天晚上 20:00" -ForegroundColor Cyan
Write-Host "执行内容: 自动检测并更新 OpenClaw" -ForegroundColor Cyan


