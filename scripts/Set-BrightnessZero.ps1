# Set brightness to 0 at midnight
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class Brightness {
    [DllImport("user32.dll")]
    public static extern IntPtr SendMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);
    
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();
    
    public static void SetBrightness(int level) {
        IntPtr hWnd = GetForegroundWindow();
        SendMessage(hWnd, 0x0112, (IntPtr)0xF170, (IntPtr)level);
    }
}
"@

[Brightness]::SetBrightness(0)
Write-Host "Brightness set to 0 at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
