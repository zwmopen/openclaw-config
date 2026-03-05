# Claudian 代理启动脚本
# 使用联通元景 API

$env:ANTHROPIC_PROXY_BASE_URL = "https://maas-api.ai-yuanjing.com/openapi/compatible-mode/v1"
$env:PORT = "3000"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Claudian 代理启动中..." -ForegroundColor Cyan
Write-Host "  后端: 联通元景 GLM-5" -ForegroundColor Green
Write-Host "  代理地址: http://localhost:3000" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "在 Claudian 设置里配置:" -ForegroundColor White
Write-Host "  ANTHROPIC_BASE_URL = http://localhost:3000" -ForegroundColor Yellow
Write-Host "  ANTHROPIC_API_KEY = 你的联通元景API Key" -ForegroundColor Yellow
Write-Host ""
Write-Host "按 Ctrl+C 停止代理" -ForegroundColor Gray
Write-Host ""

anthropic-proxy
