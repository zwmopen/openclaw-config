<#
.SYNOPSIS
    创建OpenClaw开机自动更新任务计划
.DESCRIPTION
    每天开机后自动检查更新一次
.EXAMPLE
    以管理员身份运行: .\setup-auto-update.ps1
#>

$taskName = "OpenClaw-AutoUpdate"
$scriptPath = "D:\openclaw\update-openclaw.ps1"

$existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
if ($existingTask) {
    Write-Host "任务计划已存在，正在更新..." -ForegroundColor Yellow
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}

try {
    $action = New-ScheduledTaskAction `
        -Execute "powershell.exe" `
        -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptPath`" -AutoUpdate"

    $trigger = New-ScheduledTaskTrigger -AtLogon

    $settings = New-ScheduledTaskSettingsSet `
        -StartWhenAvailable `
        -DontStopOnIdleEnd `
        -AllowStartIfOnBatteries `
        -DontStopIfGoingOnBatteries `
        -RunOnlyIfNetworkAvailable

    $principal = New-ScheduledTaskPrincipal `
        -UserId $env:USERNAME `
        -LogonType Interactive `
        -RunLevel Highest

    Register-ScheduledTask `
        -TaskName $taskName `
        -Action $action `
        -Trigger $trigger `
        -Settings $settings `
        -Principal $principal `
        -Description "每天开机后自动检查并更新OpenClaw（每天只运行一次）" -ErrorAction Stop

    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  任务计划创建成功！" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "任务名称: $taskName"
    Write-Host "触发条件: 用户登录时（每天只运行一次）"
    Write-Host "脚本路径: $scriptPath"
    Write-Host ""
    Write-Host "特点：" -ForegroundColor Cyan
    Write-Host "- 每天开机后自动运行一次"
    Write-Host "- 同一天多次开机会自动跳过"
    Write-Host "- 有网络时才运行"
    Write-Host "- 后台静默运行"
} catch {
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "  需要管理员权限！" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "请按以下步骤手动创建任务计划：" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "方法一：右键PowerShell -> 以管理员身份运行"
    Write-Host "然后执行: .\setup-auto-update.ps1"
    Write-Host ""
    Write-Host "方法二：手动创建任务计划"
    Write-Host "1. 按 Win+R，输入 taskschd.msc，回车"
    Write-Host "2. 右侧点击 '创建任务'"
    Write-Host "3. 名称填: OpenClaw-AutoUpdate"
    Write-Host "4. 触发器: '登录时'"
    Write-Host "5. 操作: 启动程序"
    Write-Host "   程序: powershell.exe"
    Write-Host "   参数: -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptPath`" -AutoUpdate"
}

Write-Host ""
Write-Host "管理命令:" -ForegroundColor Cyan
Write-Host "  查看任务: Get-ScheduledTask -TaskName '$taskName'"
Write-Host "  手动运行: Start-ScheduledTask -TaskName '$taskName'"
Write-Host "  删除任务: Unregister-ScheduledTask -TaskName '$taskName'"
Write-Host "  强制更新: .\update-openclaw.ps1 -Force"

