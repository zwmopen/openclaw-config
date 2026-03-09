# OpenClaw 定时任务修复脚本
# 需要管理员权限运行

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "OpenClaw 定时任务修复" -ForegroundColor Cyan
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

# 1. 删除 OpenClaw_OpenADrive 任务
Write-Host "1️⃣ 删除旧的 OpenClaw_OpenADrive 任务..." -ForegroundColor Yellow

$task = Get-ScheduledTask -TaskName "\OpenClaw_OpenADrive" -ErrorAction SilentlyContinue
if ($task) {
    Unregister-ScheduledTask -TaskName "\OpenClaw_OpenADrive" -Confirm:$false
    Write-Host "✅ 已删除 OpenClaw_OpenADrive" -ForegroundColor Green
} else {
    Write-Host "⚠️ 任务不存在" -ForegroundColor DarkGray
}

# 2. 重新创建 OpenClaw_OpenADrive 任务（带 -WindowStyle Hidden）
Write-Host ""
Write-Host "2️⃣ 创建新的 OpenClaw_OpenADrive 任务..." -ForegroundColor Yellow

$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File 'D:\AI编程\openclaw\scripts\open-adrive.ps1'"
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 9:00AM
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopOnIdleEnd -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest

Register-ScheduledTask -TaskName "\OpenClaw_OpenADrive" -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description "每周日 09:00 自动打开阿里云盘同步" | Out-Null

Write-Host "✅ 已创建 OpenClaw_OpenADrive（带 -WindowStyle Hidden）" -ForegroundColor Green

# 3. 删除 OpenClaw-Scan 任务
Write-Host ""
Write-Host "3️⃣ 删除 OpenClaw-Scan 任务..." -ForegroundColor Yellow

$task = Get-ScheduledTask -TaskName "\OpenClaw-Scan" -ErrorAction SilentlyContinue
if ($task) {
    Unregister-ScheduledTask -TaskName "\OpenClaw-Scan" -Confirm:$false
    Write-Host "✅ 已删除 OpenClaw-Scan（每1分钟执行的废弃任务）" -ForegroundColor Green
} else {
    Write-Host "⚠️ 任务不存在或已禁用" -ForegroundColor DarkGray
}

# 4. 检查其他任务的 -WindowStyle Hidden 参数
Write-Host ""
Write-Host "4️⃣ 检查其他任务..." -ForegroundColor Yellow

$tasks = @(
    "\OpenClaw-Daily-Reminder",
    "\OpenClaw-Daily-Update-Check",
    "\OpenClaw-GitHub-Backup",
    "\OpenClaw_MidnightBrightness",
    "\OpenClaw_MorningBrightness",
    "\OpenClaw-Gateway-KeepAlive"
)

foreach ($taskName in $tasks) {
    $task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if ($task) {
        $action = $task.Actions[0]
        $args = $action.Arguments
        
        if ($args -match "-WindowStyle Hidden") {
            Write-Host "✅ $taskName 已包含 -WindowStyle Hidden" -ForegroundColor Green
        } else {
            Write-Host "⚠️ $taskName 缺少 -WindowStyle Hidden" -ForegroundColor Yellow
            
            # 添加 -WindowStyle Hidden
            $newArgs = $args -replace "powershell\.exe -ExecutionPolicy Bypass", "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden"
            $newArgs = $args -replace "powershell\.exe -WindowStyle Hidden -ExecutionPolicy Bypass", "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden"
            
            if ($newArgs -eq $args) {
                $newArgs = $args + " -WindowStyle Hidden"
            }
            
            $newAction = New-ScheduledTaskAction -Execute $action.Execute -Argument $newArgs
            Set-ScheduledTask -TaskName $taskName -Action $newAction | Out-Null
            Write-Host "✅ 已修复 $taskName" -ForegroundColor Green
        }
    } else {
        Write-Host "⚠️ $taskName 不存在" -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "修复完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "修复内容：" -ForegroundColor Cyan
Write-Host "  ✅ OpenClaw_OpenADrive 已重新创建（带 -WindowStyle Hidden）" -ForegroundColor Green
Write-Host "  ✅ OpenClaw-Scan 已删除（废弃任务）" -ForegroundColor Green
Write-Host "  ✅ 其他任务已检查 -WindowStyle Hidden 参数" -ForegroundColor Green
Write-Host ""
Write-Host "按任意键关闭..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
