@echo off
chcp 65001 >nul
title OpenClaw

echo Starting OpenClaw...
cd /d "D:\AI编程\openclaw"

cmd /c "cd /d D:\AI编程\openclaw && powershell -NoExit -ExecutionPolicy Bypass -File scripts\start-gateway.ps1"

echo Starting Panel...
cmd /c "cd /d D:\AI编程\openclaw && node panel\server.js"

echo.
echo ========================================
echo   Started!
echo ========================================
echo.
echo   Gateway: http://127.0.0.1:18789
echo   Panel: http://localhost:38789
echo.

timeout /t 3 /nobreak >nul
start http://localhost:38789

echo Press any key to exit...
pause >nul
