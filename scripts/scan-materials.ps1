# Material Scanning Script - Simplified Version
param([int]$BatchSize = 50)

$stateFile = "D:\Program Files\Obsidian\zwm\.zwm\01-个人成长内容生产\04-素材库\扫描状态.json"
$knowledgeBasePath = "D:\Program Files\Obsidian\zwm\.zwm\个人知识库"

# Read state
$state = Get-Content $stateFile -Encoding UTF8 | ConvertFrom-Json

# Check status
if ($state.status -ne "running") {
    Write-Output "Status: not running"
    exit 0
}

# Get current directory
$dirs = @("01-flomo闪念", "02-我的幕布", "03-微信读书", "04-和AI聊天的库", "05-印象笔记", "06-飞书批量导出")
$currentDir = $state.currentDir
$scanned = $state.scanned
$total = $state.total

# Check if completed
if ($scanned -ge $total) {
    $state.status = "completed"
    $state | ConvertTo-Json -Depth 10 | Set-Content $stateFile -Encoding UTF8
    Write-Output "Status: completed"
    exit 0
}

# Scan files
$files = Get-ChildItem "$knowledgeBasePath\$currentDir" -Recurse -File -Filter "*.md" -ErrorAction SilentlyContinue | Select-Object -Skip $scanned -First $BatchSize

if ($files.Count -eq 0) {
    $idx = [array]::IndexOf($dirs, $currentDir)
    if ($idx -lt $dirs.Count - 1) {
        $currentDir = $dirs[$idx + 1]
        $state.currentDir = $currentDir
        $files = Get-ChildItem "$knowledgeBasePath\$currentDir" -Recurse -File -Filter "*.md" -ErrorAction SilentlyContinue | Select-Object -First $BatchSize
    }
}

$concepts = @()
$quotes = @()

foreach ($file in $files) {
    try {
        $content = Get-Content $file.FullName -Encoding UTF8 -Raw
        if ($content -match "^#\s+(.+)" -and $content.Length -gt 200) {
            $title = $matches[1].Trim()
            if ($title.Length -gt 5 -and $title.Length -lt 100) {
                $concepts += $title
            }
        }
    } catch {}
}

# Update state
$state.scanned += $files.Count
$state.remaining = $total - $state.scanned
$state.concepts.completed += $concepts.Count
$state.quotes.completed += $quotes.Count
$state.concepts.progress = [math]::Round($state.concepts.completed / $state.concepts.target * 100, 1).ToString() + "%"
$state.quotes.progress = [math]::Round($state.quotes.completed / $state.quotes.target * 100, 1).ToString() + "%"
$state.cases.progress = [math]::Round($state.cases.completed / $state.cases.target * 100, 1).ToString() + "%"
$state.lastScanCount = $files.Count
$state.totalScans += 1
$state.lastUpdate = Get-Date -Format "yyyy-MM-dd HH:mm"

# Save state
$state | ConvertTo-Json -Depth 10 | Set-Content $stateFile -Encoding UTF8

# Output
Write-Output "Scanned: $($files.Count) files"
Write-Output "Concepts: +$($concepts.Count)"
Write-Output "Total: $($state.scanned) / $($state.total)"
Write-Output "Progress: $($state.concepts.progress)"

if ($state.scanned % 200 -eq 0) {
    Write-Output "[REPORT]"
}
