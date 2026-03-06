# OpenClaw Gateway Keep-Alive System Installer
# Create a complete keep-alive system with notifications

Write-Host "========================================" -ForegroundColor Green
Write-Host "  OpenClaw Keep-Alive System Installer" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

$scriptDir = "D:\AI编程\openclaw\scripts"
$keepaliveScript = Join-Path $scriptDir "keepalive-gateway.ps1"

# 1. Check if keepalive script exists
Write-Host "[1/4] Checking keepalive script..." -ForegroundColor Yellow
if (Test-Path $keepaliveScript) {
    Write-Host "  [OK] keepalive-gateway.ps1 exists" -ForegroundColor Green
} else {
    Write-Host "  [X] keepalive-gateway.ps1 not found at: $keepaliveScript" -ForegroundColor Red
    exit 1
}

# 2. Install keep-alive task (run every 5 minutes)
Write-Host ""
Write-Host "[2/4] Installing keep-alive task (every 5 minutes)..." -ForegroundColor Yellow

$taskName = "OpenClaw-Gateway-KeepAlive"
$existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue

if ($existingTask) {
    Write-Host "  [!] Task exists, updating..." -ForegroundColor Yellow
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
}

$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 5)
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$keepaliveScript`"" -WorkingDirectory $scriptDir
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopOnIdleEnd -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -RunOnlyIfNetworkAvailable:$false
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited

Register-ScheduledTask -TaskName $taskName -Trigger $trigger -Action $action -Settings $settings -Principal $principal -Description "OpenClaw Gateway Keep-Alive (check every 5 minutes)" | Out-Null
Write-Host "  [OK] Keep-alive task installed: $taskName" -ForegroundColor Green

# 3. Update existing check task
Write-Host ""
Write-Host "[3/4] Updating gateway check task..." -ForegroundColor Yellow

$checkTaskName = "OpenClaw-Gateway-Check"
$checkTask = Get-ScheduledTask -TaskName $checkTaskName -ErrorAction SilentlyContinue

if ($checkTask) {
    Write-Host "  [!] Task exists, updating..." -ForegroundColor Yellow
    Unregister-ScheduledTask -TaskName $checkTaskName -Confirm:$false -ErrorAction SilentlyContinue
}

# Run every 6 hours + at login
$triggers = @(
    (New-ScheduledTaskTrigger -Once -At "06:00" -RepetitionInterval (New-TimeSpan -Hours 6)),
    (New-ScheduledTaskTrigger -AtLogon)
)
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$keepaliveScript`"" -WorkingDirectory $scriptDir
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopOnIdleEnd -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited

Register-ScheduledTask -TaskName $checkTaskName -Trigger $triggers -Action $action -Settings $settings -Principal $principal -Description "OpenClaw Gateway Check (every 6 hours)" | Out-Null
Write-Host "  [OK] Task updated: $checkTaskName" -ForegroundColor Green

# 4. Test the system
Write-Host ""
Write-Host "[4/4] Testing keep-alive system..." -ForegroundColor Yellow

# Check current status
$gatewayRunning = Get-NetTCPConnection -LocalPort 18789 -State Listen -ErrorAction SilentlyContinue
if ($gatewayRunning) {
    Write-Host "  [OK] Gateway is running (PID: $($gatewayRunning.OwningProcess))" -ForegroundColor Green
    Write-Host "      Keep-alive system will check every 5 minutes" -ForegroundColor Gray
} else {
    Write-Host "  [!] Gateway not running, starting..." -ForegroundColor Yellow
    Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File `"$keepaliveScript`"" -Wait
}

# Show summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Installation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Keep-Alive System:" -ForegroundColor Cyan
Write-Host "  - Check interval: every 5 minutes" -ForegroundColor White
Write-Host "  - Auto-restart: enabled" -ForegroundColor White
Write-Host "  - Status notifications: enabled" -ForegroundColor White
Write-Host ""
Write-Host "Tasks:" -ForegroundColor Cyan
Write-Host "  - OpenClaw-Gateway-KeepAlive (every 5 min)" -ForegroundColor White
Write-Host "  - OpenClaw-Gateway-Check (every 6 hours)" -ForegroundColor White
Write-Host "  - OpenClaw-Gateway-AutoStart (at login)" -ForegroundColor White
Write-Host ""
Write-Host "Notifications:" -ForegroundColor Cyan
Write-Host "  - Gateway offline -> send warning" -ForegroundColor White
Write-Host "  - Gateway restart -> send notification" -ForegroundColor White
Write-Host "  - Gateway online -> send confirmation" -ForegroundColor White
Write-Host ""

# Show all tasks
Write-Host "All OpenClaw Tasks:" -ForegroundColor Cyan
Get-ScheduledTask | Where-Object {$_.TaskName -like "*OpenClaw*"} | Select-Object TaskName, State, Description | Format-Table -AutoSize
