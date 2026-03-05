@echo off
chcp 65001 >nul
echo ========================================
echo   Claudian 代理启动器
echo ========================================
echo.
echo   使用: 联通元景 API
echo   代理地址: http://localhost:3000
echo.
echo   启动后，在 Claudian 设置里配置:
echo   ANTHROPIC_BASE_URL=http://localhost:3000
echo.
echo ========================================
echo.
set ANTHROPIC_PROXY_BASE_URL=https://maas-api.ai-yuanjing.com/openapi/compatible-mode/v1
set PORT=3000
anthropic-proxy
pause
