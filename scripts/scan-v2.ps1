# Scan Script V2
param([int]$BatchSize = 50)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$basePath = "D:\Program Files\Obsidian\zwm\.zwm"
$stateFile = "$basePath\02-ZWM 2.0 内容生产系统\01-内容生产\03-内容素材库\扫描状态.json"
$kbPath = "$basePath\个人知识库"
$conceptFile = "$basePath\02-ZWM 2.0 内容生产系统\01-内容生产\03-内容素材库\核心概念库.md"
$quoteFile = "$basePath\02-ZWM 2.0 内容生产系统\01-内容生产\03-内容素材库\金句库.md"

function Is-Quote {
    param([string]$s)
    if ($s.Length -lt 5 -or $s.Length -gt 100) { return $false }
    if ($s -notmatch '(不是|而是|决定|本质|核心|关键|像|就是|认知|财富|价值|规律)') { return $false }
    if ($s -match '不是.+而是') { return $true }
    if ($s -match '不是.+是') { return $true }
    if ($s -match '.+的本质是') { return $true }
    if ($s -match '.+决定.+') { return $true }
    if ($s -match '.+像.+') { return $true }
    if ($s -match '.+就是.+') { return $true }
    if ($s -match '你(赚不到|得不到|无法).+认知') { return $true }
    if ($s -match '(不要|别).+要') { return $true }
    return $false
}

$state = Get-Content $stateFile -Encoding UTF8 | ConvertFrom-Json
if ($state.status -ne "running") { Write-Output "Status: not running"; exit 0 }

$dirs = @("01-flomo闪念", "02-我的幕布", "03-微信读书", "04-和AI聊天的库", "05-印象笔记", "06-飞书批量导出")
$files = Get-ChildItem "$kbPath\$($state.currentDir)" -Recurse -File -Filter "*.md" -ErrorAction SilentlyContinue | Select-Object -Skip $state.scanned -First $BatchSize

if ($files.Count -eq 0) {
    $idx = [array]::IndexOf($dirs, $state.currentDir)
    if ($idx -lt $dirs.Count - 1) {
        $state.currentDir = $dirs[$idx + 1]
        $state.scanned = 0
        $files = Get-ChildItem "$kbPath\$($state.currentDir)" -Recurse -File -Filter "*.md" -ErrorAction SilentlyContinue | Select-Object -First $BatchSize
    } else {
        $state.status = "completed"
        $state | ConvertTo-Json -Depth 10 | Set-Content $stateFile -Encoding UTF8
        Write-Output "Status: completed"
        exit 0
    }
}

$quotes = @()
$concepts = @()

foreach ($file in $files) {
    try {
        $content = Get-Content $file.FullName -Encoding UTF8 -Raw
        if ($content -match "^#\s+(.+)" -and $content.Length -gt 200) {
            $title = $matches[1].Trim()
            if ($title -match '(法则|定律|原理|方法|技巧|模型|思维|框架|策略|原则|理论|体系|系统|认知|概念|本质|规律)') {
                $concepts += $title
            }
        }
        $sentences = $content -split '[。！？\n]'
        foreach ($s in $sentences) {
            $s = $s.Trim()
            if (Is-Quote -s $s) { $quotes += $s }
        }
    } catch {}
}

$state.scanned += $files.Count
$state.quotes.completed += $quotes.Count
$state.concepts.completed += $concepts.Count
$state.quotes.progress = [math]::Round($state.quotes.completed / $state.quotes.target * 100, 1).ToString() + "%"
$state.concepts.progress = [math]::Round($state.concepts.completed / $state.concepts.target * 100, 1).ToString() + "%"
$state.lastUpdate = Get-Date -Format "yyyy-MM-dd HH:mm"

$state | ConvertTo-Json -Depth 10 | Set-Content $stateFile -Encoding UTF8

if ($quotes.Count -gt 0) {
    $text = "`n`n### " + (Get-Date -Format "yyyy-MM-dd HH:mm") + "`n`n"
    foreach ($q in $quotes | Select-Object -Unique) { $text += "> `"$q`"`n`n" }
    Add-Content -Path $quoteFile -Value $text -Encoding UTF8
}

Write-Output "Done: $($files.Count) files, +$($quotes.Count) quotes, +$($concepts.Count) concepts"
Write-Output "Total: $($state.scanned)/$($state.total), Quotes: $($state.quotes.completed), Concepts: $($state.concepts.completed)"
