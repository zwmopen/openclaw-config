@echo off
chcp 65001 >nul
title OpenClaw Gateway 重启

echo.
echo ========================================
echo   OpenClaw Gateway 一键重启
echo ========================================
echo.

REM 设置环境变量
set OPENCLAW_STATE_DIR=d:\AICode\openclaw\.openclaw

echo [1/3] 停止现有 Gateway...
taskkill /f /im node.exe /fi "WINDOWTITLE eq OpenClaw*" 2>nul
timeout /t 2 /nobreak >nul

echo [2/3] 清理旧进程...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :18789 ^| findstr LISTENING') do (
    echo 正在终止进程 %%a
    taskkill /f /pid %%a 2>nul
)
timeout /t 2 /nobreak >nul

echo [3/3] 启动新 Gateway...
start "OpenClaw Gateway" /min "" "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node.exe" "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node_modules\openclaw\openclaw.mjs" gateway

timeout /t 5 /nobreak >nul

echo.
echo ========================================
echo   Gateway 已重启！
echo   端口: 18789
echo   状态: http://127.0.0.1:18789
echo ========================================
echo.

timeout /t 3 /nobreak >nul
