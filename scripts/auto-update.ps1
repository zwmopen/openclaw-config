# OpenClaw 自动更新检查脚本
# 每天检查一次是否有新版本，有则自动更新

param(
    [switch]$Force,
    [switch]$Quiet
)

$ErrorActionPreference = "SilentlyContinue"

function Write-Log {
    param($Message, $Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logFile = "D:\AICode\openclaw\logs\update.log"
    $logDir = Split-Path $logFile -Parent
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }
    $logEntry = "[$timestamp] [$Level] $Message"
    Add-Content -Path $logFile -Value $logEntry
    if (-not $Quiet) {
        switch ($Level) {
            "INFO" { Write-Host $Message -ForegroundColor Green }
            "WARN" { Write-Host $Message -ForegroundColor Yellow }
            "ERROR" { Write-Host $Message -ForegroundColor Red }
        }
    }
}

function Get-CurrentVersion {
    try {
        $result = & openclaw --version 2>&1
        if ($result -match "(\d+\.\d+\.\d+[-\d]*)") {
            return $matches[1]
        }
        return "unknown"
    } catch {
        return "unknown"
    }
}

function Get-LatestVersion {
    try {
        $response = Invoke-RestMethod -Uri "https://registry.npmjs.org/openclaw/latest" -Method Get -TimeoutSec 10
        return $response.version
    } catch {
        Write-Log "无法获取最新版本信息: $_" "WARN"
        return $null
    }
}

function Update-OpenClaw {
    param($Version)
    Write-Log "开始更新 OpenClaw 到版本 $Version..."
    
    try {
        # 更新 npm 包
        $result = npm update -g openclaw 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Log "OpenClaw 更新成功！" "INFO"
            return $true
        } else {
            Write-Log "更新失败: $result" "ERROR"
            return $false
        }
    } catch {
        Write-Log "更新出错: $_" "ERROR"
        return $false
    }
}

# 主逻辑
Write-Log "=== OpenClaw 自动更新检查 ==="

$currentVersion = Get-CurrentVersion
Write-Log "当前版本: $currentVersion"

$latestVersion = Get-LatestVersion
if (-not $latestVersion) {
    Write-Log "无法检查更新，跳过本次检查" "WARN"
    exit 0
}

Write-Log "最新版本: $latestVersion"

if ($currentVersion -eq $latestVersion) {
    Write-Log "已是最新版本，无需更新"
    exit 0
}

if ($currentVersion -ne "unknown" -and $latestVersion) {
    Write-Log "发现新版本！$currentVersion -> $latestVersion"
    
    if ($Force) {
        Update-OpenClaw -Version $latestVersion
    } else {
        Write-Log "使用 -Force 参数自动更新" "WARN"
    }
}

# 记录检查时间
$updateCheckFile = "D:\AICode\openclaw\.openclaw\update-check.json"
$checkData = @{
    lastCheck = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
    currentVersion = $currentVersion
    latestVersion = $latestVersion
    needsUpdate = ($currentVersion -ne $latestVersion)
}
$checkData | ConvertTo-Json | Out-File $updateCheckFile -Encoding utf8


