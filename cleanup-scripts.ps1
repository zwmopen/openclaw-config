# OpenClaw Gateway 脚本清理

Write-Host "OpenClaw Gateway 脚本清理" -ForegroundColor Cyan
Write-Host ""

# 保留的脚本
$keep = @(
    "start-gateway-interactive.ps1",
    "restart-gateway-interactive.ps1",
    "check-gateway-interactive.ps1",
    "keepalive-simple.ps1",
    "daily-reminder.ps1",
    "auto-backup-github.ps1",
    "auto-update.ps1"
)

# 列出所有 gateway/start 相关脚本
$scripts = Get-ChildItem "D:\AI编程\openclaw\scripts" -Filter "*.ps1" | Where-Object {
    $_.Name -like "*gateway*" -or $_.Name -like "*start*" -or $_.Name -like "*restart*"
}

Write-Host "找到以下脚本：" -ForegroundColor Yellow
$scripts | ForEach-Object { Write-Host "  $($_.Name)" -ForegroundColor Gray }

Write-Host ""
Write-Host "建议保留的脚本：" -ForegroundColor Green
$keep | ForEach-Object { Write-Host "  $_" -ForegroundColor Green }

Write-Host ""
Write-Host "建议删除的脚本：" -ForegroundColor Red
$scripts | Where-Object { $_.Name -notin $keep } | ForEach-Object { Write-Host "  $($_.Name)" -ForegroundColor Red }

Write-Host ""
Write-Host "是否删除这些脚本？(Y/N)" -ForegroundColor Yellow
$answer = Read-Host

if ($answer -eq 'Y' -or $answer -eq 'y') {
    $scripts | Where-Object { $_.Name -notin $keep } | ForEach-Object {
        Remove-Item $_.FullName -Force
        Write-Host "✅ 已删除: $($_.Name)" -ForegroundColor Green
    }
    Write-Host ""
    Write-Host "清理完成！" -ForegroundColor Green
} else {
    Write-Host "取消删除" -ForegroundColor Yellow
}
