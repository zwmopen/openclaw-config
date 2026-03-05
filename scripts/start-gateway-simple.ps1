Set-Location "D:\AI编程\openclaw"
$env:OPENCLAW_STATE_DIR = ".\.openclaw"
$env:OPENCLAW_CONFIG_PATH = ".\.openclaw\openclaw.json"
& "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node.exe" "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node_modules\openclaw\openclaw.mjs" gateway
