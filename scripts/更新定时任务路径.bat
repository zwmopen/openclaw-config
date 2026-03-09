@echo off
:: 自动请求管理员权限
if "%1"=="admin" (
    powershell -ExecutionPolicy Bypass -File "%~dp0更新定时任务路径.ps1"
) else (
    echo 正在请求管理员权限...
    powershell -Command "Start-Process '%~f0' -Verb RunAs -ArgumentList 'admin'"
)
