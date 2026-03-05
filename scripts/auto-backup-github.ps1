# OpenClaw 自动备份到 GitHub
# 每天自动提交并推送到 GitHub

param(
    [switch]$Force,
    [switch]$Quiet
)

$BaseDir = "D:\AI编程\openclaw"
$LogFile = "D:\AI编程\openclaw\log\github-backup.log"

# 确保日志目录存在
$logDir = Split-Path $LogFile -Parent
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

function Write-Log {
    param($Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $Message"
    Add-Content -Path $LogFile -Value $logEntry
    if (-not $Quiet) {
        Write-Host $logEntry
    }
}

# 切换到工作目录
Set-Location $BaseDir

# 检查是否有变更
$status = git status --porcelain 2>$null
if ($status.Count -eq 0 -and -not $Force) {
    Write-Log "没有变更，跳过备份"
    exit 0
}

Write-Log "开始备份..."

# 获取当前日期时间
$commitDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$commitMessage = "自动备份 - $commitDate"

# 添加所有变更
git add . 2>$null

# 提交
$commitResult = git commit -m $commitMessage 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Log "✅ 提交成功: $commitMessage"
} else {
    Write-Log "⚠️ 提交失败或无变更"
}

# 推送
$pushResult = git push origin main 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Log "✅ 推送成功"
} else {
    Write-Log "❌ 推送失败: $pushResult"
}

# 记录文件统计
$fileCount = (git ls-files | Measure-Object).Count
$commitCount = (git rev-list --count main 2>$null)
Write-Log "📊 仓库统计: $fileCount 个文件, $commitCount 次提交"

Write-Log "备份完成"
