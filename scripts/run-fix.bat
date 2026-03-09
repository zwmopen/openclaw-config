@echo off
echo Requesting administrator permission...
echo Please click YES in the next window.
echo.
pause
PowerShell -Command "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"D:\AICode\openclaw\scripts\fix-tasks.ps1\"' -Verb RunAs"
echo.
echo Done! Check the administrator window for results.
pause


