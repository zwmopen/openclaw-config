# 验证符号链接和定时任务
# 检查所有更新是否成功

Write-Host "=== 验证更新结果 ===" -ForegroundColor Cyan
Write-Host ""

# 1. 检查符号链接
Write-Host "1. D:\openclaw 符号链接：" -ForegroundColor Yellow
if (Test-Path "D:\openclaw") {
    $item = Get-Item "D:\openclaw"
    if ($item.LinkType -eq "SymbolicLink") {
        Write-Host "  ✅ 符号链接存在" -ForegroundColor Green
        Write-Host "  目标：$($item.Target)" -ForegroundColor Cyan
    } else {
        Write-Host "  ⚠️ 路径存在但不是符号链接" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ❌ 符号链接不存在" -ForegroundColor Red
    Write-Host "  需要创建：D:\openclaw → D:\AI编程\openclaw" -ForegroundColor Yellow
}

# 2. 检查Obsidian软链接
Write-Host ""
Write-Host "2. Obsidian 软链接：" -ForegroundColor Yellow
$obsidianLink = "D:\Program Files\Obsidian\zwm\.zwm\OpenClaw配置"
if (Test-Path $obsidianLink) {
    $item = Get-Item $obsidianLink
    if ($item.LinkType) {
        Write-Host "  ✅ 链接存在" -ForegroundColor Green
        Write-Host "  目标：$($item.Target)" -ForegroundColor Cyan
    } else {
        Write-Host "  ⚠️ 路径存在但不是链接" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ❌ 链接不存在" -ForegroundColor Red
}

# 3. 检查OpenClaw配置
Write-Host ""
Write-Host "3. OpenClaw 配置：" -ForegroundColor Yellow
$configFile = "D:\AI编程\openclaw\.openclaw\openclaw.json"
if (Test-Path $configFile) {
    $config = Get-Content $configFile -Raw | ConvertFrom-Json
    $workspace = $config.agents.defaults.workspace
    Write-Host "  workspace: $workspace" -ForegroundColor Cyan
    if ($workspace -eq "D:\openclaw") {
        Write-Host "  ✅ 配置已更新" -ForegroundColor Green
    } else {
        Write-Host "  ❌ 配置未更新" -ForegroundColor Red
    }
} else {
    Write-Host "  ❌ 配置文件不存在" -ForegroundColor Red
}

# 4. 检查定时任务
Write-Host ""
Write-Host "4. Windows 定时任务：" -ForegroundColor Yellow
$tasks = @(
    "OpenClaw_MorningBrightness",
    "OpenClaw_NightBrightness",
    "OpenClaw_GitHubBackup"
)

foreach ($taskName in $tasks) {
    $task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if ($task) {
        $action = $task.Actions[0]
        if ($action.Arguments -match "D:\\openclaw") {
            Write-Host "  ✅ $taskName (已更新为新路径)" -ForegroundColor Green
        } elseif ($action.Arguments -match "D:\\AI编程\\openclaw") {
            Write-Host "  ⚠️ $taskName (仍使用中文路径)" -ForegroundColor Yellow
        } else {
            Write-Host "  ✅ $taskName (存在)" -ForegroundColor Green
        }
    } else {
        Write-Host "  ❌ $taskName (不存在)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== 完成 ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "按任意键退出..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
