@echo off
chcp 65001 >nul 2>&1
set "NODE_PATH=C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node_modules"
set "OPENCLAW_STATE_DIR=D:\AI编程\openclaw\.openclaw"
set "OPENCLAW_CONFIG_PATH=D:\AI编程\openclaw\.openclaw\openclaw.json"
cd /d "D:\AI编程\openclaw"
"C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node.exe" "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node_modules\openclaw\openclaw.mjs" %*
