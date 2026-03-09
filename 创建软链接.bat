Set-Location "D:\AI编程\openclaw"
$scriptPath = "D:\AI编程\openclaw\scripts\创建OpenClaw软链接.ps1"

# 以管理员权限运行
Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
