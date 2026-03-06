# 音乐模式脚本
# 用途：一键启动音乐播放
# 触发：用户说"音乐模式"或"播放音乐"

Write-Host "🎵 启动音乐模式..." -ForegroundColor Cyan

# 1. 调节音量到50%
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Volume {
    [DllImport("user32.dll")]
    public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, int dwExtraInfo);
}
"@

# 先静音再取消静音（确保状态）
[Volume]::keybd_event(0xAD, 0, 0, 0)  # Volume Mute
Start-Sleep -Milliseconds 100
[Volume]::keybd_event(0xAD, 0, 0, 0)  # Volume Mute again to unmute

# 调到最大（按50次音量+）
for ($i = 0; $i -lt 50; $i++) {
    [Volume]::keybd_event(0xAF, 0, 0, 0)  # Volume Up
    Start-Sleep -Milliseconds 50
}

# 调到50%（按25次音量-）
for ($i = 0; $i -lt 25; $i++) {
    [Volume]::keybd_event(0xAE, 0, 0, 0)  # Volume Down
    Start-Sleep -Milliseconds 50
}

Write-Host "✅ 音量已调到50%" -ForegroundColor Green

# 2. 启动网易云音乐
Start-Process "D:\Program Files\Netease\CloudMusic\cloudmusic.exe"
Write-Host "✅ 网易云音乐已启动" -ForegroundColor Green

# 3. 等待20秒让软件加载
Write-Host "⏳ 等待网易云音乐加载（20秒）..." -ForegroundColor Yellow
for ($i = 20; $i -gt 0; $i--) {
    Write-Host "倒计时: $i 秒" -ForegroundColor DarkGray
    Start-Sleep -Seconds 1
}

# 4. 发送空格键播放
$wshell = New-Object -ComObject WScript.Shell
$wshell.AppActivate('网易云音乐')
Start-Sleep -Milliseconds 500
$wshell.SendKeys(' ')
Write-Host "✅ 已发送空格键，音乐开始播放！" -ForegroundColor Green

Write-Host "`n🎵 音乐模式启动完成！" -ForegroundColor Cyan
