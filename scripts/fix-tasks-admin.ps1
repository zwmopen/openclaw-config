# OpenClaw 定时任务清理脚本（管理员权限）
# 需要右键以管理员身份运行

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "OpenClaw 定时任务清理" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查管理员权限
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "❌ 需要管理员权限运行此脚本！" -ForegroundColor Red
    Write-Host ""
    Write-Host "请右键点击此脚本，选择'以管理员身份运行'" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "按任意键关闭..." -ForegroundColor DarkGray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Host "✅ 已获取管理员权限" -ForegroundColor Green
Write-Host ""

# 1. 更新 OpenClaw-Gateway-AutoStart
Write-Host "1️⃣ 更新 OpenClaw-Gateway-AutoStart..." -ForegroundColor Yellow

Unregister-ScheduledTask -TaskName "\OpenClaw-Gateway-AutoStart" -Confirm:$false -ErrorAction SilentlyContinue
Write-Host "✅ 已删除旧任务" -ForegroundColor Green

$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File 'D:\openclaw\scripts\OpenClaw.ps1' -NoTimeout"
$trigger = New-ScheduledTaskTrigger -AtLogon
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopOnIdleEnd -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest

Register-ScheduledTask -TaskName "\OpenClaw-Gateway-AutoStart" -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description "开机自动启动 OpenClaw Gateway" | Out-Null
Write-Host "✅ 已创建新任务" -ForegroundColor Green

# 2. 删除 OpenClaw-Gateway-Check
Write-Host ""
Write-Host "2️⃣ 删除 OpenClaw-Gateway-Check..." -ForegroundColor Yellow

Unregister-ScheduledTask -TaskName "\OpenClaw-Gateway-Check" -Confirm:$false -ErrorAction SilentlyContinue
Write-Host "✅ 已删除" -ForegroundColor Green

# 3. 修复 OpenClaw_OpenADrive
Write-Host ""
Write-Host "3️⃣ 修复 OpenClaw_OpenADrive..." -ForegroundColor Yellow

Unregister-ScheduledTask -TaskName "\OpenClaw_OpenADrive" -Confirm:$false -ErrorAction SilentlyContinue
Write-Host "✅ 已删除旧任务" -ForegroundColor Green

$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File 'D:\openclaw\scripts\open-adrive.ps1'"
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 9:00AM
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopOnIdleEnd -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest

Register-ScheduledTask -TaskName "\OpenClaw_OpenADrive" -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description "每周日 09:00 自动打开阿里云盘同步" | Out-Null
Write-Host "✅ 已创建新任务（带 -WindowStyle Hidden）" -ForegroundColor Green

# 4. 删除 OpenClaw_Restart_Reminder
Write-Host ""
Write-Host "4️⃣ 删除 OpenClaw_Restart_Reminder..." -ForegroundColor Yellow

Unregister-ScheduledTask -TaskName "\OpenClaw_Restart_Reminder" -Confirm:$false -ErrorAction SilentlyContinue
Write-Host "✅ 已删除" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "清理完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "修复内容：" -ForegroundColor Cyan
Write-Host "  ✅ OpenClaw-Gateway-AutoStart 已更新（指向新脚本）" -ForegroundColor Green
Write-Host "  ✅ OpenClaw-Gateway-Check 已删除（废弃任务）" -ForegroundColor Green
Write-Host "  ✅ OpenClaw_OpenADrive 已修复（带 -WindowStyle Hidden）" -ForegroundColor Green
Write-Host "  ✅ OpenClaw_Restart_Reminder 已删除（废弃任务）" -ForegroundColor Green
Write-Host ""
Write-Host "按任意键关闭..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

