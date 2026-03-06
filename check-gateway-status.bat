@echo off
chcp 65001 >nul 2>&1
title OpenClaw Gateway Status

echo ========================================
echo   OpenClaw Gateway Status
echo ========================================
echo.

echo Checking Gateway status...
echo.

netstat -ano | findstr ":18789" | findstr "LISTENING" >nul
if %errorlevel% equ 0 (
    echo [OK] Gateway is running on port 18789
    echo.
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":18789" ^| findstr "LISTENING"') do (
        echo     PID: %%a
    )
) else (
    echo [X] Gateway is NOT running
    echo.
    echo     Run start-gateway-reliable.bat to start it.
)

echo.
echo ========================================
echo.
pause
