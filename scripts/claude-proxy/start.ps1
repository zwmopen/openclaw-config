# 启动Claude代理服务器（前台运行，用于测试）

Write-Host "启动Claude代理服务器..." -ForegroundColor Yellow
Write-Host "端口: 15721" -ForegroundColor Cyan
Write-Host "目标API: https://maas-api.ai-yuanjing.com" -ForegroundColor Cyan
Write-Host "按Ctrl+C停止" -ForegroundColor Gray
Write-Host ""

node server.js
