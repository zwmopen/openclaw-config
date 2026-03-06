# 工作模式脚本
# 用途：一键启动工作环境
# 触发：用户说"工作模式"或"开始工作"

Write-Host "💼 启动工作模式..." -ForegroundColor Cyan

# 1. 调节亮度到70%
$brightness = 70
try {
    (Get-WmiObject -Namespace root/WMI -Class WmiMonitorBrightnessMethods).WmiSetBrightness(1, $brightness)
    Write-Host "✅ 亮度已调到 $brightness%" -ForegroundColor Green
} catch {
    Write-Host "⚠️ 亮度调节失败" -ForegroundColor Yellow
}

# 2. 调节音量到30%
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Volume {
    [DllImport("user32.dll")]
    public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, int dwExtraInfo);
}
"@

[Volume]::keybd_event(0xAD, 0, 0, 0)  # Volume Mute
Start-Sleep -Milliseconds 100
[Volume]::keybd_event(0xAD, 0, 0, 0)  # Volume Mute again to unmute

# 调到最大
for ($i = 0; $i -lt 50; $i++) {
    [Volume]::keybd_event(0xAF, 0, 0, 0)
    Start-Sleep -Milliseconds 50
}

# 调到30%（按35次音量-）
for ($i = 0; $i -lt 35; $i++) {
    [Volume]::keybd_event(0xAE, 0, 0, 0)
    Start-Sleep -Milliseconds 50
}

Write-Host "✅ 音量已调到30%" -ForegroundColor Green

# 3. 打开Obsidian
Start-Process "D:\Program Files\Obsidian\Obsidian.exe"
Write-Host "✅ Obsidian已启动" -ForegroundColor Green

# 4. 等待3秒
Start-Sleep -Seconds 3

# 5. 打开浏览器（可选）
# Start-Process "chrome.exe"
# Write-Host "✅ 浏览器已启动" -ForegroundColor Green

Write-Host "`n💼 工作模式启动完成！" -ForegroundColor Cyan
Write-Host "建议：打开任务清单，开始今天的工作！" -ForegroundColor Yellow
