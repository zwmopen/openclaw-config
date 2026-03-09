# 创建Windows定时任务（需要管理员权限）
# 请右键以管理员身份运行此脚本

Write-Host "=== 创建定时任务 ===" -ForegroundColor Cyan
Write-Host ""

# 1. 晚上0:00亮度调节
Write-Host "1. 创建晚上0:00亮度调节任务..." -ForegroundColor Yellow
$action1 = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"D:\AICode\openclaw\scripts\SetBrightness-Night.ps1`""
$trigger1 = New-ScheduledTaskTrigger -Daily -At 0:00
$settings1 = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
$principal1 = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest

try {
    Register-ScheduledTask -TaskName "OpenClaw_NightBrightness" -Action $action1 -Trigger $trigger1 -Settings $settings1 -Principal $principal1 -Description "每天0:00调节亮度到0%" -Force | Out-Null
    Write-Host "  ? 晚上0:00亮度调节任务已创建" -ForegroundColor Green
} catch {
    Write-Host "  ? 创建失败: $_" -ForegroundColor Red
}

# 2. 每天0:00 GitHub备份
Write-Host "2. 创建每天0:00 GitHub备份任务..." -ForegroundColor Yellow
$action2 = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"D:\AICode\openclaw\scripts\GitHubBackup.ps1`""
$trigger2 = New-ScheduledTaskTrigger -Daily -At 0:00
$settings2 = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
$principal2 = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest

try {
    Register-ScheduledTask -TaskName "OpenClaw_GitHubBackup" -Action $action2 -Trigger $trigger2 -Settings $settings2 -Principal $principal2 -Description "每天0:00自动备份到GitHub" -Force | Out-Null
    Write-Host "  ? GitHub备份任务已创建" -ForegroundColor Green
} catch {
    Write-Host "  ? 创建失败: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== 完成 ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "已创建的定时任务：" -ForegroundColor Yellow
Write-Host "  1. OpenClaw_MorningBrightness - 每天7:00亮度调到50%"
Write-Host "  2. OpenClaw_NightBrightness - 每天0:00亮度调到0%"
Write-Host "  3. OpenClaw_GitHubBackup - 每天0:00备份到GitHub"
Write-Host ""
Write-Host "查看所有任务："
Write-Host "  schtasks /query /tn OpenClaw_* /fo TABLE"
Write-Host ""
Write-Host "按任意键退出..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")


