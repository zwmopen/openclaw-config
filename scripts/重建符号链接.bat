@echo off
:: 自动请求管理员权限，创建符号链接

if "%1"=="admin" (
    echo 正在创建符号链接...
    echo.

    :: 删除旧链接（如果存在）
    if exist "D:\openclaw" (
        echo 删除旧链接...
        rmdir "D:\openclaw"
    )

    :: 创建新链接
    echo 创建符号链接：D:\openclaw -^> D:\AI编程\openclaw
    mklink /D "D:\openclaw" "D:\AI编程\openclaw"

    if exist "D:\openclaw" (
        echo.
        echo ✅ 符号链接创建成功！
        echo.

        :: 创建Obsidian软链接
        echo 创建Obsidian软链接...
        if exist "D:\Program Files\Obsidian\zwm\.zwm\OpenClaw配置" (
            rmdir "D:\Program Files\Obsidian\zwm\.zwm\OpenClaw配置"
        )
        mklink /D "D:\Program Files\Obsidian\zwm\.zwm\OpenClaw配置" "D:\openclaw"

        if exist "D:\Program Files\Obsidian\zwm\.zwm\OpenClaw配置" (
            echo ✅ Obsidian软链接创建成功！
        )
    ) else (
        echo ❌ 创建失败
    )

    echo.
    pause
) else (
    echo 正在请求管理员权限...
    powershell -Command "Start-Process '%~f0' -Verb RunAs -ArgumentList 'admin'"
)
