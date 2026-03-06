@echo off
chcp 65001 >nul 2>&1
title Restart OpenClaw Gateway

echo ========================================
echo   Restart OpenClaw Gateway
echo ========================================
echo.

REM 切换到工作目录
cd /d "%~dp0"

echo [1/3] Stopping existing Gateway...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":18789" ^| findstr "LISTENING"') do (
    echo     Killing process %%a...
    taskkill /F /PID %%a >nul 2>&1
)
timeout /t 2 /nobreak >nul

echo [2/3] Starting new Gateway...
echo.

REM 设置环境变量
set "OPENCLAW_STATE_DIR=%~dp0.openclaw"
set "OPENCLAW_CONFIG_PATH=%~dp0.openclaw\openclaw.json"

REM 启动网关（后台运行）
start "" /min "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node.exe" "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node_modules\openclaw\openclaw.mjs" gateway

echo [3/3] Verifying...
timeout /t 3 /nobreak >nul

netstat -ano | findstr ":18789" | findstr "LISTENING" >nul
if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo   Success! Gateway is running.
    echo ========================================
    echo.
    echo   Gateway: ws://127.0.0.1:18789
    echo.
) else (
    echo.
    echo ========================================
    echo   Failed to start Gateway.
    echo ========================================
    echo.
    echo   Check logs in: %~dp0.openclaw\logs\
    echo.
)

echo Press any key to exit...
pause >nul
