# Mute system volume using Windows Core Audio API
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

[Guid("5CDF2C82-841E-4546-9722-0CF74078229A"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IAudioEndpointVolume {
    int SetMasterVolumeLevelScalar(float fLevel, Guid pguidEventContext);
    int GetMasterVolumeLevelScalar(out float pfLevel);
    int SetMute(bool bMute, Guid pguidEventContext);
    int GetMute(out bool pbMute);
}

[Guid("D666063F-1587-4E43-81F1-B948E807363F"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IMMDevice {
    int Activate(ref Guid id, int dwClsCtx, IntPtr pActivationParams, out IAudioEndpointVolume aev);
}

[Guid("A95664D2-9614-4F35-A746-DE8DB63617E6"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IMMDeviceEnumerator {
    int GetDefaultAudioEndpoint(int dataFlow, int role, out IMMDevice endpoint);
}

[ComImport, Guid("BCDE0395-E52F-467C-8E3D-C4579291692E")]
class MMDeviceEnumeratorComObject { }

public class Audio {
    static IAudioEndpointVolume GetVolumeControl() {
        var enumerator = new MMDeviceEnumeratorComObject() as IMMDeviceEnumerator;
        IMMDevice device;
        enumerator.GetDefaultAudioEndpoint(0, 0, out device);
        Guid iid = typeof(IAudioEndpointVolume).GUID;
        IAudioEndpointVolume aev;
        device.Activate(ref iid, 0, IntPtr.Zero, out aev);
        return aev;
    }
    
    public static void SetVolume(float level) {
        var aev = GetVolumeControl();
        aev.SetMasterVolumeLevelScalar(level, Guid.Empty);
    }
    
    public static void Mute() {
        var aev = GetVolumeControl();
        aev.SetMute(true, Guid.Empty);
    }
}
"@

[Audio]::SetVolume(0)
[Audio]::Mute()
Write-Host "System volume muted at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
