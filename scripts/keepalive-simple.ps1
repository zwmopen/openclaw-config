# OpenClaw Gateway Keep-Alive Script (Simplified)
# Check gateway status every 5 minutes and restart if needed

$gatewayUrl = "http://127.0.0.1:18789"
$stateFile = "D:\openclaw\.openclaw\gateway-state.json"
$logFile = "D:\openclaw\.openclaw\keepalive.log"
$nodeExe = "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node.exe"
$openclawMjs = "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node_modules\openclaw\openclaw.mjs"
$stateDir = "D:\openclaw\.openclaw"
$configPath = "D:\openclaw\.openclaw\openclaw.json"

function Write-Log {
    param($message, $level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "[$timestamp][$level] $message" | Out-File -FilePath $logFile -Append -Encoding UTF8
}

function Get-GatewayStatus {
    try {
        $response = Invoke-WebRequest -Uri "$gatewayUrl/health" -TimeoutSec 5 -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

function Start-Gateway {
    Write-Log "Starting OpenClaw Gateway..." "WARN"
    
    $env:OPENCLAW_STATE_DIR = $stateDir
    $env:OPENCLAW_CONFIG_PATH = $configPath
    
    Start-Process -FilePath $nodeExe -ArgumentList $openclawMjs, "gateway" -WindowStyle Hidden
    
    Start-Sleep -Seconds 5
    
    $status = Get-GatewayStatus
    if ($status) {
        Write-Log "Gateway started successfully" "INFO"
        return $true
    } else {
        Write-Log "Failed to start gateway" "ERROR"
        return $false
    }
}

# Check gateway
$currentStatus = Get-GatewayStatus
$previousStatus = $null

if (Test-Path $stateFile) {
    $state = Get-Content $stateFile | ConvertFrom-Json
    $previousStatus = $state.online
}

@{
    online = $currentStatus
    lastCheck = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
} | ConvertTo-Json | Out-File $stateFile -Encoding UTF8

# Auto-restart if offline
if (-not $currentStatus) {
    Write-Log "Gateway offline, attempting restart..." "WARN"
    Start-Gateway
} else {
    Write-Log "Gateway online" "INFO"
}

