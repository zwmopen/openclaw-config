# Set volume to 0 (mute)
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class Volume {
    [DllImport("user32.dll")]
    public static extern IntPtr SendMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);
    
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();
    
    public static void SetVolume(int level) {
        IntPtr hWnd = GetForegroundWindow();
        // 0x0112 = WM_SYSCOMMAND, 0xF170 = SC_MONPOWER, level = 0 (mute)
        SendMessage(hWnd, 0x0112, (IntPtr)0xF170, (IntPtr)level);
    }
}
"@

[Volume]::SetVolume(0)
Write-Host "Volume set to 0 (mute) at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
