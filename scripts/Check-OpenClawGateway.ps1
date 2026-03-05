# Check if OpenClaw Gateway is running
$gatewayProcess = Get-Process node -ErrorAction SilentlyContinue | Where-Object { 
    $_.CommandLine -like '*openclaw*' -and $_.CommandLine -like '*gateway*' 
}

if (-not $gatewayProcess) {
    Write-Host "OpenClaw Gateway not running, starting..."
    Start-Process "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node.exe" -ArgumentList "--disable-warning=ExperimentalWarning C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node_modules\openclaw\openclaw.mjs gateway" -WindowStyle Hidden
    Write-Host "OpenClaw Gateway started at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
} else {
    Write-Host "OpenClaw Gateway already running at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
}
