<#
.SYNOPSIS
    OpenClaw启动/停止开关脚本
.DESCRIPTION
    一键启动或停止OpenClaw Gateway
.EXAMPLE
    .\openclaw-switch.ps1 -Action start
    .\openclaw-switch.ps1 -Action stop
    .\openclaw-switch.ps1 -Action status
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("start", "stop", "status", "restart")]
    [string]$Action
)

$lockFile = "D:\AICode\openclaw\.openclaw-running"
$logFile = "D:\AICode\openclaw\openclaw-switch.log"

function Write-Log {
    param([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $message"
    Write-Host $logEntry -ForegroundColor Cyan
    Add-Content -Path $logFile -Value $logEntry
}

function Get-OpenClawProcess {
    return Get-Process -Name "node" -ErrorAction SilentlyContinue | 
           Where-Object { $_.CommandLine -like "*openclaw*" -or $_.CommandLine -like "*gateway*" }
}

function Start-OpenClaw {
    Write-Log "正在启动OpenClaw Gateway..."
    
    $existing = Get-OpenClawProcess
    if ($existing) {
        Write-Log "OpenClaw已在运行中！PID: $($existing.Id)"
        return
    }
    
    Start-Process -FilePath "powershell.exe" `
                  -ArgumentList "-NoExit", "-Command", "cd 'D:\openclaw'; .\openclaw.bat gateway" `
                  -WindowStyle Normal
    
    "running" | Out-File -FilePath $lockFile
    Write-Log "OpenClaw Gateway 已启动！"
    Write-Log "访问地址: http://127.0.0.1:18789"
}

function Stop-OpenClaw {
    Write-Log "正在停止OpenClaw Gateway..."
    
    $processes = Get-OpenClawProcess
    if ($processes) {
        $processes | ForEach-Object {
            Write-Log "停止进程 PID: $($_.Id)"
            Stop-Process -Id $_.Id -Force
        }
        Write-Log "OpenClaw Gateway 已停止！"
    } else {
        Write-Log "未找到运行中的OpenClaw进程"
    }
    
    if (Test-Path $lockFile) {
        Remove-Item $lockFile -Force
    }
}

function Get-Status {
    $processes = Get-OpenClawProcess
    if ($processes) {
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "  OpenClaw Gateway 状态: 运行中" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "进程ID: $($processes.Id -join ', ')"
        Write-Host "启动时间: $($processes.StartTime)"
        Write-Host "内存占用: $([math]::Round($processes.WorkingSet64/1MB, 2)) MB"
        Write-Host "访问地址: http://127.0.0.1:18789"
        Write-Host "========================================" -ForegroundColor Green
    } else {
        Write-Host "========================================" -ForegroundColor Yellow
        Write-Host "  OpenClaw Gateway 状态: 已停止" -ForegroundColor Yellow
        Write-Host "========================================" -ForegroundColor Yellow
        Write-Host "运行 '.\openclaw-switch.ps1 -Action start' 启动"
    }
}

switch ($Action) {
    "start"   { Start-OpenClaw }
    "stop"    { Stop-OpenClaw }
    "status"  { Get-Status }
    "restart" { Stop-OpenClaw; Start-Sleep -Seconds 2; Start-OpenClaw }
}


