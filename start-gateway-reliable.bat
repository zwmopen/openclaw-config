@echo off
chcp 65001 >nul 2>&1
title OpenClaw Gateway

echo ========================================
echo   OpenClaw Gateway Starter
echo ========================================
echo.

REM 切换到工作目录
cd /d "%~dp0"

echo [1/2] Checking if Gateway is already running...
netstat -ano | findstr ":18789" | findstr "LISTENING" >nul
if %errorlevel% equ 0 (
    echo [!] Gateway is already running on port 18789
    echo     No need to start again.
    echo.
    goto :end
)

echo [2/2] Starting OpenClaw Gateway...
echo.

REM 设置环境变量
set "OPENCLAW_STATE_DIR=%~dp0.openclaw"
set "OPENCLAW_CONFIG_PATH=%~dp0.openclaw\openclaw.json"

REM 启动网关（后台运行）
start "" /min "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node.exe" "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node_modules\openclaw\openclaw.mjs" gateway

echo ========================================
echo   Gateway Starting...
echo ========================================
echo.
echo   Gateway: ws://127.0.0.1:18789
echo.
echo   The window will close in 5 seconds...
timeout /t 5 /nobreak >nul

:end
echo.
echo Press any key to exit...
pause >nul
