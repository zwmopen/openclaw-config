# OpenClaw Gateway Silent Start

$scriptDir = "D:\AI编程\openclaw"
$env:OPENCLAW_STATE_DIR = Join-Path $scriptDir ".openclaw"
$env:OPENCLAW_CONFIG_PATH = Join-Path $env:OPENCLAW_STATE_DIR "openclaw.json"

Start-Process -FilePath "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node.exe" `
    -ArgumentList "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node_modules\openclaw\openclaw.mjs", "gateway" `
    -WindowStyle Hidden
