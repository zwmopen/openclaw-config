@echo off
chcp 65001 >nul
title 生财有术周报抓取

echo 正在创建定时任务...
echo.
echo 需要管理员权限，请点击"是"确认。
echo.

PowerShell -Command "Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command \"New-ScheduledTaskAction -Execute ''PowerShell.exe'' -Argument ''-NoProfile -ExecutionPolicy Bypass -File D:\\AI编程\\openclaw\\scripts\\scys-weekly.ps1'' | New-ScheduledTaskTrigger -Weekly -DaysOfWeek Saturday -At 9am | New-ScheduledTaskSettingsSet -StartWhenAvailable | New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive | Register-ScheduledTask -TaskName OpenClaw_SCYS_Weekly -Force\"' -Verb RunAs"

echo.
echo 定时任务创建完成！
echo.
echo 任务名称：OpenClaw_SCYS_Weekly
echo 执行时间：每周六上午 9:00
echo 执行脚本：D:\AI编程\openclaw\scripts\scys-weekly.ps1
echo.
pause
