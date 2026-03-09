# 更新Windows定时任务，改用新的英文路径
# 需要管理员权限

Write-Host "=== 更新Windows定时任务 ===" -ForegroundColor Cyan
Write-Host ""

$newPath = "D:\openclaw"

# 定义所有定时任务
$tasks = @(
    @{
        Name = "OpenClaw_NightBrightness"
        Description = "每天0:00调节亮度到0%"
        Script = "$newPath\scripts\SetBrightness-Night.ps1"
        Trigger = "0:00"
    },
    @{
        Name = "OpenClaw_GitHubBackup"
        Description = "每天0:00自动备份到GitHub"
        Script = "$newPath\scripts\GitHubBackup.ps1"
        Trigger = "0:00"
    }
)

# 删除旧任务（如果存在）
Write-Host "1. 删除旧任务..." -ForegroundColor Yellow
foreach ($task in $tasks) {
    $existing = Get-ScheduledTask -TaskName $task.Name -ErrorAction SilentlyContinue
    if ($existing) {
        Unregister-ScheduledTask -TaskName $task.Name -Confirm:$false
        Write-Host "  ✅ 已删除：$($task.Name)" -ForegroundColor Green
    }
}

# 创建新任务
Write-Host ""
Write-Host "2. 创建新任务..." -ForegroundColor Yellow
foreach ($task in $tasks) {
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$($task.Script)`""
    $trigger = New-ScheduledTaskTrigger -Daily -At $task.Trigger
    $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
    $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest

    try {
        Register-ScheduledTask -TaskName $task.Name -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description $task.Description -Force | Out-Null
        Write-Host "  ✅ 已创建：$($task.Name)" -ForegroundColor Green
    } catch {
        Write-Host "  ❌ 创建失败：$($task.Name) - $_" -ForegroundColor Red
    }
}

# 更新现有的其他任务
Write-Host ""
Write-Host "3. 更新其他任务路径..." -ForegroundColor Yellow
$otherTasks = @(
    "OpenClaw_MorningBrightness",
    "OpenClaw_DailyReminder",
    "OpenClaw_AutoUpdate",
    "OpenClaw_GatewayKeepalive"
)

foreach ($taskName in $otherTasks) {
    $task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if ($task) {
        # 更新任务路径
        $action = $task.Actions[0]
        if ($action.Arguments -match "D:\\AI编程\\openclaw") {
            $newArgs = $action.Arguments -replace "D:\\AI编程\\openclaw", $newPath
            $newAction = New-ScheduledTaskAction -Execute $action.Execute -Argument $newArgs
            Set-ScheduledTask -TaskName $taskName -Action $newAction | Out-Null
            Write-Host "  ✅ 已更新：$taskName" -ForegroundColor Green
        } else {
            Write-Host "  ⏭️ 跳过：$taskName (路径已更新)" -ForegroundColor Cyan
        }
    }
}

Write-Host ""
Write-Host "=== 完成 ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "所有定时任务已更新为使用英文路径：$newPath" -ForegroundColor Yellow
Write-Host ""
Write-Host "按任意键退出..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
