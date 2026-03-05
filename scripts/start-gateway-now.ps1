$env:OPENCLAW_STATE_DIR = "D:\AI编程\openclaw\.openclaw"
$env:OPENCLAW_CONFIG_PATH = "D:\AI编程\openclaw\.openclaw\openclaw.json"

Write-Host "Starting OpenClaw Gateway..." -ForegroundColor Cyan

Start-Process -FilePath "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node.exe" -ArgumentList "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node_modules\openclaw\openclaw.mjs", "gateway"

Start-Sleep -Seconds 3

Write-Host "Checking port 18789..." -ForegroundColor Yellow
$connection = Get-NetTCPConnection -LocalPort 18789 -ErrorAction SilentlyContinue
if ($connection) {
    Write-Host "OpenClaw Gateway is running on port 18789" -ForegroundColor Green
} else {
    Write-Host "OpenClaw Gateway failed to start" -ForegroundColor Red
}

Write-Host "Opening browser..." -ForegroundColor Cyan
Start-Process "http://localhost:38789"
