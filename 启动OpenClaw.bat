@echo off
cd /d "%~dp0"
echo 启动 OpenClaw Gateway...
powershell -WindowStyle Hidden -Command "Start-Process -FilePath 'C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node.exe' -ArgumentList 'C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node_modules\openclaw\openclaw.mjs','gateway' -WindowStyle Hidden"
echo 已启动！访问 http://127.0.0.1:18789 查看
pause
