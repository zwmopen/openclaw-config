<#
.SYNOPSIS
    一键启动OpenClaw控制面板
.DESCRIPTION
    启动后端服务器并打开浏览器
.EXAMPLE
    双击运行或在PowerShell中执行: .\启动控制面板.ps1
#>

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$serverScript = Join-Path $scriptPath "openclaw-panel-server.ps1"

Write-Host "========================================" -ForegroundColor Green
Write-Host "  OpenClaw 控制面板启动器" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Start-Process "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -NoExit -File `"$serverScript`""
Start-Sleep -Seconds 2
Start-Process "http://localhost:8080"

Write-Host "控制面板已在浏览器中打开" -ForegroundColor Cyan
Write-Host "关闭此窗口不会影响控制面板运行" -ForegroundColor Yellow
