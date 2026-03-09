@echo off
REM OpenClaw Gateway 启动脚本 - 使用D盘配置目录

echo 正在启动 OpenClaw Gateway...

REM 设置环境变量指向D盘
set OPENCLAW_STATE_DIR=d:\AICode\openclaw\.openclaw

REM 启动gateway
start /b "" "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node.exe" "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node_modules\openclaw\openclaw.mjs" gateway

echo OpenClaw Gateway 已启动！
echo 访问 http://127.0.0.1:18789 查看状态
pause
