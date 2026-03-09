# 设置屏幕亮度到0%（最低）
Write-Host "设置屏幕亮度到0%..." -ForegroundColor Yellow

try {
    # 方法1：WMI方式
    $monitor = Get-WmiObject -Namespace root/WMI -Class WmiMonitorBrightnessMethods
    if ($monitor) {
        $monitor.WmiSetBrightness(1, 0)
        Write-Host "✅ 亮度已设置为0%（WMI方式）" -ForegroundColor Green
    } else {
        Write-Host "⚠️ WMI方式不支持，尝试其他方式..." -ForegroundColor Yellow
        
        # 方法2：PowerShell 5.1方式
        Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Brightness {
    [DllImport("user32.dll")]
    public static extern IntPtr SendMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);
    public static void SetBrightness(int brightness) {
        SendMessage((IntPtr)0xFFFF, 0x0112, (IntPtr)0xF170, (IntPtr)brightness);
    }
}
"@
        [Brightness]::SetBrightness(0)
        Write-Host "✅ 亮度已设置为0%（SendMessage方式）" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ 设置亮度失败: $_" -ForegroundColor Red
    Write-Host "请手动调节屏幕亮度" -ForegroundColor Yellow
}
