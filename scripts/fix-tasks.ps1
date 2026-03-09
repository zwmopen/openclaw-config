# Fix OpenClaw scheduled tasks - No more popup windows
# Run as Administrator

Write-Host ""
Write-Host "=== Fixing OpenClaw Scheduled Tasks ===" -ForegroundColor Cyan
Write-Host ""

# Remove old tasks
Write-Host "Removing old tasks..." -ForegroundColor Yellow
Unregister-ScheduledTask -TaskName "OpenClaw_MorningBrightness" -Confirm:$false -ErrorAction SilentlyContinue
Unregister-ScheduledTask -TaskName "OpenClaw-Gateway-AutoStart" -Confirm:$false -ErrorAction SilentlyContinue
Write-Host "Done" -ForegroundColor Green

# Create new tasks with -WindowStyle Hidden
Write-Host "Creating new tasks..." -ForegroundColor Yellow

# Task 1: Morning brightness (7:00 AM)
$action1 = New-ScheduledTaskAction -Execute "powershell.exe" -Argument '-ExecutionPolicy Bypass -WindowStyle Hidden -File "D:\openclaw\scripts\SetBrightness.ps1"'
$trigger1 = New-ScheduledTaskTrigger -Daily -At 7:00
$settings1 = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopOnIdleEnd -AllowStartIfOnBatteries
Register-ScheduledTask -TaskName "OpenClaw_MorningBrightness" -Action $action1 -Trigger $trigger1 -Settings $settings1 -RunLevel Highest -Force | Out-Null
Write-Host "  [OK] OpenClaw_MorningBrightness" -ForegroundColor Green

# Task 2: Gateway auto start (at logon)
$action2 = New-ScheduledTaskAction -Execute "powershell.exe" -Argument '-ExecutionPolicy Bypass -WindowStyle Hidden -File "D:\openclaw\scripts\start-gateway-hidden.ps1"'
$trigger2 = New-ScheduledTaskTrigger -AtLogon
$settings2 = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopOnIdleEnd -AllowStartIfOnBatteries
Register-ScheduledTask -TaskName "OpenClaw-Gateway-AutoStart" -Action $action2 -Trigger $trigger2 -Settings $settings2 -RunLevel Highest -Force | Out-Null
Write-Host "  [OK] OpenClaw-Gateway-AutoStart" -ForegroundColor Green

Write-Host ""
Write-Host "=== Fix Complete! No more popup windows ===" -ForegroundColor Green
Write-Host ""
pause

