@echo off
chcp 65001 >nul
title OpenClaw Test

echo Starting OpenClaw Gateway...
cd /d "D:\AI编程\openclaw"
powershell -NoExit -ExecutionPolicy Bypass -File "scripts\start-gateway.ps1"

echo Starting OpenClaw Panel...
node "panel\server.js"

echo.
echo Services started!
echo.
echo Gateway: http://127.0.0.1:18789
echo Panel: http://localhost:38789
echo.
pause
