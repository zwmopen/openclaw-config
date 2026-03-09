@echo off
REM OpenClaw Gateway 智能启动脚本
REM 自动判断状态，智能执行启动/重启/检查

cd /d "%~dp0"
powershell.exe -ExecutionPolicy Bypass -NoExit -File "OpenClaw.ps1"
