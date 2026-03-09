$stateFile = "D:\Program Files\Obsidian\zwm\.zwm\02-ZWM 2.0 内容生产系统\01-内容生产\03-内容素材库\扫描状态.json"
$kbPath = "D:\Program Files\Obsidian\zwm\.zwm\个人知识库"

$state = Get-Content $stateFile -Encoding UTF8 | ConvertFrom-Json
$dirs = @("01-flomo闪念", "02-我的幕布", "03-微信读书", "04-和AI聊天的库", "05-印象笔记", "06-飞书批量导出")

if ($state.status -ne "running") {
    Write-Output "Status: $($state.status)"
    exit
}

$currentDir = $state.currentDir
$dirPath = Join-Path $kbPath $currentDir
$allFiles = @(Get-ChildItem $dirPath -Recurse -File -Filter *.md -ErrorAction SilentlyContinue)
$files = $allFiles | Select-Object -Skip $state.scanned -First 50

if ($files.Count -eq 0) {
    $idx = [array]::IndexOf($dirs, $currentDir)
    if ($idx -lt $dirs.Count - 1) {
        $state.currentDir = $dirs[$idx + 1]
        $state.scanned = 0
        Write-Output "Switch to: $($state.currentDir)"
    } else {
        $state.status = "completed"
        Write-Output "Completed!"
    }
} else {
    $concepts = 0
    $quotes = 0
    $cases = 0
    
    foreach ($file in $files) {
        $content = Get-Content $file.FullName -Encoding UTF8 -Raw -ErrorAction SilentlyContinue
        if ($content) {
            if ($content -match "(本质|规律|原则|核心|底层逻辑|第一性原理|方法论|关键|重要)") { $concepts++ }
            if ($content -match "(所谓|真正的|重要的|关键的|记住|明白|发现|其实|不是.*而是|因为.*所以|只有.*才|没有.*就)") { $quotes++ }
            if ($content -match "(案例|例子|故事|经历|实践|实操|落地|应用)") { $cases++ }
        }
    }
    
    $state.scanned += $files.Count
    $state.concepts.completed += $concepts
    $state.quotes.completed += $quotes
    $state.cases.completed += $cases
    $state.concepts.progress = [math]::Round($state.concepts.completed / $state.concepts.target * 100, 1).ToString() + "%"
    $state.quotes.progress = [math]::Round($state.quotes.completed / $state.quotes.target * 100, 1).ToString() + "%"
    $state.cases.progress = [math]::Round($state.cases.completed / $state.cases.target * 100, 1).ToString() + "%"
    $state.lastScanCount = $files.Count
    $state.totalScans++
    $state.lastUpdate = Get-Date -Format "yyyy-MM-dd HH:mm"
    
    $progress = [math]::Round($state.scanned / $state.total * 100, 1)
    Write-Output "Scanned: $($files.Count) files"
    Write-Output "Concepts: +$concepts (Total: $($state.concepts.completed)/$($state.concepts.target))"
    Write-Output "Quotes: +$quotes (Total: $($state.quotes.completed)/$($state.quotes.target))"
    Write-Output "Cases: +$cases (Total: $($state.cases.completed)/$($state.cases.target))"
    Write-Output "Progress: $($state.scanned)/$($state.total) ($progress percent)"
}

$state | ConvertTo-Json -Depth 10 | Set-Content $stateFile -Encoding UTF8
