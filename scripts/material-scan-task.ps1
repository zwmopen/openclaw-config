# OpenClaw Material Scan Task - Final Version
$stateFile = 'D:\Program Files\Obsidian\zwm\.zwm\01-个人成长内容生产\04-素材库\扫描状态.json'
$knowledgeBasePath = 'D:\Program Files\Obsidian\zwm\.zwm\个人知识库'
$logFile = 'D:\AICode\openclaw\logs\scan.log'

try {
    $state = Get-Content $stateFile -Encoding UTF8 | ConvertFrom-Json
    if ($state.status -ne 'running') { exit 0 }
    if ($state.scanned -ge $state.total) {
        $state.status = 'completed'
        $state | ConvertTo-Json -Depth 10 | Out-File $stateFile -Encoding UTF8
        exit 0
    }
    
    $dirs = @('01-flomo闪念', '02-我的幕布', '03-微信读书', '04-和AI聊天的库', '05-印象笔记', '06-飞书批量导出')
    $currentDir = $state.currentDir
    $files = Get-ChildItem "$knowledgeBasePath\$currentDir" -Recurse -File -Filter *.md | Select-Object -Skip $state.scanned -First 50
    
    if ($files.Count -eq 0) {
        $idx = [array]::IndexOf($dirs, $currentDir)
        if ($idx -lt $dirs.Count - 1) {
            $currentDir = $dirs[$idx + 1]
            $state.currentDir = $currentDir
            $files = Get-ChildItem "$knowledgeBasePath\$currentDir" -Recurse -File -Filter *.md | Select-Object -First 50
        }
    }
    
    $concepts = 0
    foreach ($file in $files) {
        $content = Get-Content $file.FullName -Encoding UTF8 -Raw
        if ($content -match '^#\s+(.+)' -and $content.Length -gt 200) { $concepts++ }
    }
    
    $state.scanned += $files.Count
    $state.remaining = $state.total - $state.scanned
    $state.concepts.completed += $concepts
    $state.concepts.progress = [math]::Round($state.concepts.completed / $state.concepts.target * 100, 1).ToString() + '%'
    $state.quotes.progress = [math]::Round($state.quotes.completed / $state.quotes.target * 100, 1).ToString() + '%'
    $state.cases.progress = [math]::Round($state.cases.completed / $state.cases.target * 100, 1).ToString() + '%'
    $state.lastScanCount = $files.Count
    $state.totalScans += 1
    $state.lastUpdate = Get-Date -Format 'yyyy-MM-dd HH:mm'
    
    $state | ConvertTo-Json -Depth 10 | Out-File $stateFile -Encoding UTF8
    
    $ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logDir = Split-Path $logFile -Parent
    if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
    "[$ts] Scanned $($files.Count) files, +$concepts concepts, total $($state.scanned)/$($state.total)" | Out-File $logFile -Append -Encoding UTF8
    
    if ($state.scanned % 200 -eq 0) {
        "[$ts] REPORT NODE: $($state.scanned) files scanned" | Out-File $logFile -Append -Encoding UTF8
    }
} catch {
    $ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logDir = Split-Path $logFile -Parent
    if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
    "[$ts] Error: $_" | Out-File $logFile -Append -Encoding UTF8
}


