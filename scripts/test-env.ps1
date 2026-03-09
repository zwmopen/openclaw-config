$env:NODE_PATH = "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node_modules"
$env:OPENCLAW_STATE_DIR = "D:\AICode\openclaw\.openclaw"
$env:OPENCLAW_CONFIG_PATH = "D:\AICode\openclaw\.openclaw\openclaw.json"

Set-Location "D:\openclaw"

Write-Host "Testing environment variables..." -ForegroundColor Cyan
Write-Host "OPENCLAW_STATE_DIR = $env:OPENCLAW_STATE_DIR" -ForegroundColor Yellow
Write-Host "OPENCLAW_CONFIG_PATH = $env:OPENCLAW_CONFIG_PATH" -ForegroundColor Yellow
Write-Host "Current Directory = $PWD" -ForegroundColor Yellow

$testCode = @'
console.log("=== Node.js Environment Check ===");
console.log("OPENCLAW_STATE_DIR:", process.env.OPENCLAW_STATE_DIR);
console.log("OPENCLAW_CONFIG_PATH:", process.env.OPENCLAW_CONFIG_PATH);
console.log("PWD:", process.cwd());
console.log("=================================");
'@

$testCode | & "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node.exe" -


