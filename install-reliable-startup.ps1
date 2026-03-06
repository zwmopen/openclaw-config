# OpenClaw Reliable Startup System Installer

Write-Host "========================================" -ForegroundColor Green
Write-Host "  OpenClaw Reliable Startup Installer" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$batFiles = @(
    "start-gateway-reliable.bat",
    "restart-gateway-reliable.bat", 
    "check-gateway-status.bat"
)

# 1. Check if all scripts exist
Write-Host "[1/5] Checking startup scripts..." -ForegroundColor Yellow
$allExist = $true
foreach ($bat in $batFiles) {
    $path = Join-Path $scriptDir $bat
    if (Test-Path $path) {
        Write-Host "  [OK] $bat" -ForegroundColor Green
    } else {
        Write-Host "  [X] $bat not found" -ForegroundColor Red
        $allExist = $false
    }
}

if (-not $allExist) {
    Write-Host ""
    Write-Host "[ERROR] Startup scripts incomplete. Please create them first." -ForegroundColor Red
    exit 1
}

# 2. Create desktop shortcuts
Write-Host ""
Write-Host "[2/5] Creating desktop shortcuts..." -ForegroundColor Yellow

$WshShell = New-Object -ComObject WScript.Shell
$desktopPath = [System.Environment]::GetFolderPath("Desktop")

# Main startup shortcut
$shortcutPath = Join-Path $desktopPath "OpenClaw-Start.lnk"
$shortcut = $WshShell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = Join-Path $scriptDir "start-gateway-reliable.bat"
$shortcut.WorkingDirectory = $scriptDir
$shortcut.Description = "Start OpenClaw Gateway"
$shortcut.Save()
Write-Host "  [OK] Desktop shortcut: $shortcutPath" -ForegroundColor Green

# Restart shortcut
$restartShortcutPath = Join-Path $desktopPath "OpenClaw-Restart.lnk"
$restartShortcut = $WshShell.CreateShortcut($restartShortcutPath)
$restartShortcut.TargetPath = Join-Path $scriptDir "restart-gateway-reliable.bat"
$restartShortcut.WorkingDirectory = $scriptDir
$restartShortcut.Description = "Restart OpenClaw Gateway"
$restartShortcut.Save()
Write-Host "  [OK] Desktop shortcut: $restartShortcutPath" -ForegroundColor Green

# Status check shortcut
$statusShortcutPath = Join-Path $desktopPath "OpenClaw-Status.lnk"
$statusShortcut = $WshShell.CreateShortcut($statusShortcutPath)
$statusShortcut.TargetPath = Join-Path $scriptDir "check-gateway-status.bat"
$statusShortcut.WorkingDirectory = $scriptDir
$statusShortcut.Description = "Check OpenClaw Gateway Status"
$statusShortcut.Save()
Write-Host "  [OK] Desktop shortcut: $statusShortcutPath" -ForegroundColor Green

# 3. Create startup entry
Write-Host ""
Write-Host "[3/5] Creating startup entry..." -ForegroundColor Yellow

$startupPath = [System.Environment]::GetFolderPath("Startup")
$startupShortcutPath = Join-Path $startupPath "OpenClaw-Gateway.lnk"
$startupShortcut = $WshShell.CreateShortcut($startupShortcutPath)
$startupShortcut.TargetPath = Join-Path $scriptDir "start-gateway-reliable.bat"
$startupShortcut.WorkingDirectory = $scriptDir
$startupShortcut.Description = "OpenClaw Gateway AutoStart"
$startupShortcut.Save()
Write-Host "  [OK] Startup entry: $startupShortcutPath" -ForegroundColor Green

# 4. Create scheduled task (more reliable)
Write-Host ""
Write-Host "[4/5] Creating scheduled task (more reliable)..." -ForegroundColor Yellow

$taskName = "OpenClaw-Gateway-AutoStart"
$taskExists = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue

if ($taskExists) {
    Write-Host "  [!] Task exists, updating..." -ForegroundColor Yellow
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
}

$trigger = New-ScheduledTaskTrigger -AtLogon -User $env:USERNAME
$action = New-ScheduledTaskAction -Execute (Join-Path $scriptDir "start-gateway-reliable.bat") -WorkingDirectory $scriptDir
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopOnIdleEnd -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited

Register-ScheduledTask -TaskName $taskName -Trigger $trigger -Action $action -Settings $settings -Principal $principal -Description "OpenClaw Gateway AutoStart" | Out-Null
Write-Host "  [OK] Scheduled task: $taskName" -ForegroundColor Green

# 5. Test startup script
Write-Host ""
Write-Host "[5/5] Testing startup script..." -ForegroundColor Yellow

# Check if gateway is already running
$gatewayRunning = Get-NetTCPConnection -LocalPort 18789 -State Listen -ErrorAction SilentlyContinue

if ($gatewayRunning) {
    Write-Host "  [OK] Gateway already running (PID: $($gatewayRunning.OwningProcess))" -ForegroundColor Green
    Write-Host "      No need to restart" -ForegroundColor Gray
} else {
    Write-Host "  [!] Gateway not running, attempting to start..." -ForegroundColor Yellow
    Start-Process -FilePath (Join-Path $scriptDir "start-gateway-reliable.bat") -Wait
    Start-Sleep -Seconds 3
    
    $gatewayRunning = Get-NetTCPConnection -LocalPort 18789 -State Listen -ErrorAction SilentlyContinue
    if ($gatewayRunning) {
        Write-Host "  [OK] Startup successful" -ForegroundColor Green
    } else {
        Write-Host "  [X] Startup failed, please check manually" -ForegroundColor Red
    }
}

# Done
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Installation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Created:" -ForegroundColor Cyan
Write-Host "  - Desktop shortcuts: OpenClaw-Start/Restart/Status" -ForegroundColor White
Write-Host "  - Auto-start: Startup folder + Scheduled task" -ForegroundColor White
Write-Host ""
Write-Host "Usage:" -ForegroundColor Cyan
Write-Host "  1. Double-click 'OpenClaw-Start' to start gateway" -ForegroundColor White
Write-Host "  2. Double-click 'OpenClaw-Restart' to restart gateway" -ForegroundColor White
Write-Host "  3. Double-click 'OpenClaw-Status' to check status" -ForegroundColor White
Write-Host "  4. Gateway will auto-start on boot" -ForegroundColor White
Write-Host ""
