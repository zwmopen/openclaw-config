@echo off
chcp 65001 >nul 2>&1
title OpenClaw 控制面板
cd /d "%~dp0"

echo ========================================
echo   OpenClaw 控制面板启动器 v2.1
echo ========================================
echo.

:: 启动后端服务器
start "" powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0openclaw-panel-server.ps1"

:: 等待服务器启动
timeout /t 3 /nobreak >nul

:: 打开浏览器
start http://localhost:38789

echo 控制面板已在浏览器中打开！
echo 地址: http://localhost:38789
echo.
echo 关闭此窗口不会影响控制面板运行
echo 如需停止，请使用控制面板中的停止按钮
echo.
pause
