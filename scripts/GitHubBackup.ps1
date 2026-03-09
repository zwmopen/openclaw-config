# GitHub自动备份脚本
# 用途：每天0:00自动备份Obsidian和OpenClaw配置到GitHub

$ErrorActionPreference = "Continue"

Write-Host "=== GitHub自动备份 ===" -ForegroundColor Cyan
Write-Host "开始时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Yellow

# 定义备份目录
$openclawDir = "D:\openclaw"
$obsidianDir = "D:\Program Files\Obsidian\zwm\.zwm"
$backupLog = "D:\openclaw\logs\github-backup.log"

# 创建日志目录
$logDir = Split-Path $backupLog -Parent
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

# 日志函数
function Write-Log {
    param($Message)
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logEntry = "[$timestamp] $Message"
    Write-Host $logEntry
    Add-Content -Path $backupLog -Value $logEntry
}

# 备份OpenClaw
Write-Log "开始备份OpenClaw..."
Set-Location $openclawDir

try {
    # 检查是否有变更
    $status = git status --porcelain
    if ($status) {
        Write-Log "检测到变更，开始提交..."
        git add .
        $commitMsg = "Auto backup: $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
        git commit -m $commitMsg
        git push origin main
        Write-Log "✅ OpenClaw备份完成"
    } else {
        Write-Log "ℹ️ OpenClaw无变更"
    }
} catch {
    Write-Log "❌ OpenClaw备份失败: $_"
}

# 备份Obsidian
Write-Log "开始备份Obsidian..."
Set-Location $obsidianDir

try {
    # 检查是否有变更
    $status = git status --porcelain
    if ($status) {
        Write-Log "检测到变更，开始提交..."
        git add .
        $commitMsg = "Auto backup: $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
        git commit -m $commitMsg
        git push origin main
        Write-Log "✅ Obsidian备份完成"
    } else {
        Write-Log "ℹ️ Obsidian无变更"
    }
} catch {
    Write-Log "❌ Obsidian备份失败: $_"
}

Write-Log "备份完成！"
Write-Host "完成时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Yellow

