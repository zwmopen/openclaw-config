@echo off
chcp 65001 >nul 2>&1

REM 切换到工作目录
cd /d "%~dp0"

REM 停止现有 Gateway
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":18789" ^| findstr "LISTENING" 2^>nul') do (
    taskkill /F /PID %%a >nul 2>&1
)

REM 等待进程完全退出
timeout /t 2 /nobreak >nul

REM 设置环境变量
set "OPENCLAW_STATE_DIR=%~dp0.openclaw"
set "OPENCLAW_CONFIG_PATH=%~dp0.openclaw\openclaw.json"

REM 后台启动（不创建窗口）
start /b "" "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node.exe" "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node_modules\openclaw\openclaw.mjs" gateway >nul 2>&1

REM 等待启动
timeout /t 3 /nobreak >nul

REM 检查是否成功
netstat -ano | findstr ":18789" | findstr "LISTENING" >nul
if %errorlevel% equ 0 (
    echo Gateway restarted successfully on port 18789
) else (
    echo Failed to restart Gateway
)

exit /b 0
