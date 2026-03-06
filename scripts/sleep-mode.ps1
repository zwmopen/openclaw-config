# 睡觉模式脚本
# 用途：一键准备睡觉
# 触发：用户说"睡觉模式"或"准备睡觉"

Write-Host "🌙 启动睡觉模式..." -ForegroundColor Cyan

# 1. 调节亮度到0%
$brightness = 0
try {
    (Get-WmiObject -Namespace root/WMI -Class WmiMonitorBrightnessMethods).WmiSetBrightness(1, $brightness)
    Write-Host "✅ 亮度已调到 $brightness%" -ForegroundColor Green
} catch {
    Write-Host "⚠️ 亮度调节失败" -ForegroundColor Yellow
}

# 2. 静音
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Volume {
    [DllImport("user32.dll")]
    public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, int dwExtraInfo);
}
"@

[Volume]::keybd_event(0xAD, 0, 0, 0)  # Volume Mute
Write-Host "✅ 已静音" -ForegroundColor Green

# 3. 关闭网易云音乐
Stop-Process -Name "cloudmusic" -ErrorAction SilentlyContinue
Write-Host "✅ 已关闭网易云音乐" -ForegroundColor Green

# 4. 关闭浏览器（可选）
# Stop-Process -Name "chrome" -ErrorAction SilentlyContinue
# Stop-Process -Name "msedge" -ErrorAction SilentlyContinue
# Write-Host "✅ 已关闭浏览器" -ForegroundColor Green

Write-Host "`n🌙 睡觉模式启动完成！" -ForegroundColor Cyan
Write-Host "建议：清空滴答清单，准备睡觉！" -ForegroundColor Yellow
