# 修复OpenClaw计划任务（解决命令行窗口闪现问题）
# 需要以管理员身份运行

Write-Host "=== 修复 OpenClaw 计划任务 ===" -ForegroundColor Cyan
Write-Host "解决命令行窗口闪现问题" -ForegroundColor Yellow
Write-Host ""

# 1. 修复 OpenClaw_MorningBrightness（早上7点亮度调节）
Write-Host "[1/2] 修复 OpenClaw_MorningBrightness..." -ForegroundColor Cyan
Unregister-ScheduledTask -TaskName "OpenClaw_MorningBrightness" -Confirm:$false -ErrorAction SilentlyContinue

$action1 = New-ScheduledTaskAction -Execute "powershell.exe" -Argument '-ExecutionPolicy Bypass -WindowStyle Hidden -File "D:\openclaw\scripts\SetBrightness.ps1"'
$trigger1 = New-ScheduledTaskTrigger -Daily -At 7:00
$settings1 = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopOnIdleEnd -AllowStartIfOnBatteries
Register-ScheduledTask -TaskName "OpenClaw_MorningBrightness" -Action $action1 -Trigger $trigger1 -Settings $settings1 -RunLevel Highest -Force
Write-Host "  完成！" -ForegroundColor Green

# 2. 修复 OpenClaw-Gateway-AutoStart（开机启动）
Write-Host "[2/2] 修复 OpenClaw-Gateway-AutoStart..." -ForegroundColor Cyan
Unregister-ScheduledTask -TaskName "OpenClaw-Gateway-AutoStart" -Confirm:$false -ErrorAction SilentlyContinue

# 使用PowerShell而不是cmd，避免弹窗
$action2 = New-ScheduledTaskAction -Execute "powershell.exe" -Argument '-ExecutionPolicy Bypass -WindowStyle Hidden -File "D:\openclaw\scripts\start-gateway-hidden.ps1"'
$trigger2 = New-ScheduledTaskTrigger -AtLogon
$settings2 = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopOnIdleEnd -AllowStartIfOnBatteries
Register-ScheduledTask -TaskName "OpenClaw-Gateway-AutoStart" -Action $action2 -Trigger $trigger2 -Settings $settings2 -RunLevel Highest -Force
Write-Host "  完成！" -ForegroundColor Green

Write-Host ""
Write-Host "=== 修复完成 ===" -ForegroundColor Green
Write-Host "计划任务已更新，不会再弹窗了" -ForegroundColor Yellow

