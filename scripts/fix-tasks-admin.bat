@echo off
REM OpenClaw 定时任务清理脚本
REM 需要以管理员身份运行

cd /d "%~dp0"
powershell.exe -ExecutionPolicy Bypass -Command "Start-Process powershell.exe -ArgumentList '-ExecutionPolicy Bypass -File \"%~dpn0.ps1\"' -Verb RunAs"
