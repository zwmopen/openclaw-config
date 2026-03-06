@echo off
REM CC Switch 自动激活 Profile
REM 在启动时自动激活 unicom-new profile 并启动 Claude

echo Activating CC Switch profile: unicom-new...

REM 设置 CC Switch 环境变量
set CC_SWITCH_PROFILE=unicom-new

REM 激活 Profile（使用 cc-switch CLI）
cc-switch switch unicom-new

echo Profile activated. Starting Claude...

REM 启动 Claude（如果需要）
REM start "" "C:\Users\z\AppData\Local\Programs\claude\Claude.exe"

exit 0
