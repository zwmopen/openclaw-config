@echo off
chcp 65001 >nul 2>&1

REM 切换到工作目录
cd /d "%~dp0"

REM 创建状态目录
if not exist ".openclaw" mkdir ".openclaw"

REM 检查是否已在运行
netstat -ano | findstr ":18789" | findstr "LISTENING" >nul
if %errorlevel% equ 0 (
    echo Gateway already running on port 18789
    timeout /t 2 /nobreak >nul
    exit /b 0
)

REM 设置环境变量
set "OPENCLAW_STATE_DIR=%~dp0.openclaw"
set "OPENCLAW_CONFIG_PATH=%~dp0.openclaw\openclaw.json"

REM 后台启动（不创建窗口）
start "OpenClaw Gateway" /b "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node.exe" "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node_modules\openclaw\openclaw.mjs" gateway

REM 等待启动
timeout /t 5 /nobreak >nul

REM 检查是否成功
netstat -ano | findstr ":18789" | findstr "LISTENING" >nul
if %errorlevel% equ 0 (
    echo Gateway started successfully on port 18789
    echo %date% %time% Gateway started successfully >> ".openclaw\startup.log"
    exit /b 0
) else (
    echo Failed to start Gateway
    echo %date% %time% Failed to start Gateway >> ".openclaw\startup.log"
    exit /b 1
)
