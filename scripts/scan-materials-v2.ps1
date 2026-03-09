# Material Scanning Script V2 - With Golden Quote Detection
param([int]$BatchSize = 50)

$stateFile = "D:\Program Files\Obsidian\zwm\.zwm\02-ZWM 2.0 内容生产系统\01-内容生产\03-内容素材库\扫描状态.json"
$knowledgeBasePath = "D:\Program Files\Obsidian\zwm\.zwm\个人知识库"
$conceptFile = "D:\Program Files\Obsidian\zwm\.zwm\02-ZWM 2.0 内容生产系统\01-内容生产\03-内容素材库\核心概念库.md"
$quoteFile = "D:\Program Files\Obsidian\zwm\.zwm\02-ZWM 2.0 内容生产系统\01-内容生产\03-内容素材库\金句库.md"
$caseFile = "D:\Program Files\Obsidian\zwm\.zwm\02-ZWM 2.0 内容生产系统\01-内容生产\03-内容素材库\案例库.md"

# Golden Quote Detection Function
function Is-GoldenQuote {
    param([string]$sentence)
    
    # Length check
    if ($sentence.Length -lt 5 -or $sentence.Length -gt 100) {
        return $false
    }
    
    # Must have some keyword
    if ($sentence -notmatch '(不是|而是|决定|本质|核心|关键|像|就是|做|要|别|避免|提升|增加|减少|找到|选择|大于|小于|最重要|最值钱|唯一|最好|认知|财富|价值|规律|本质)') {
        return $false
    }
    
    # Pattern matching
    $patterns = @(
        # Contrast pattern
        '不是.+而是',
        '不是.+是',
        '不.+而.+',
        
        # Definition pattern
        '.+的本质是',
        '.+决定.+',
        '.+是.+最.+',
        '.+是.+核心',
        '.+是.+关键',
        
        # Causal pattern
        '.+的边界是.+的边界',
        '.+是.+变现',
        '.+是.+结果',
        
        # Metaphor pattern
        '.+像.+',
        '.+就是.+',
        '把.+比作',
        
        # Action pattern
        '(不要|别).+要',
        '做.+不做',
        '选择.+放弃',
        
        # Insight pattern
        '你(赚不到|得不到|无法).+认知',
        '.+是.+唯一.+方法',
        
        # Parallelism pattern
        '(提升|做|有).+，(提升|做|有).+，(提升|做|有)'
    )
    
    foreach ($pattern in $patterns) {
        if ($sentence -match $pattern) {
            return $true
        }
    }
    
    return $false
}

# Concept Detection Function
function Is-Concept {
    param([string]$title, [string]$content)
    
    # Title should be meaningful
    if ($title.Length -lt 3 -or $title.Length -gt 50) {
        return $false
    }
    
    # Content should be substantial
    if ($content.Length -lt 200) {
        return $false
    }
    
    # Title should have conceptual keywords
    if ($title -match '(法则|定律|原理|方法|技巧|模型|思维|框架|策略|原则|理论|体系|系统|认知|概念|本质|规律)') {
        return $true
    }
    
    return $false
}

# Case Detection Function
function Is-Case {
    param([string]$content)
    
    # Case indicators
    if ($content -match '(案例|故事|经历|经验|实践|实操|实例|例子|示范|教程|步骤|方法)') {
        return $true
    }
    
    return $false
}

# Read or create state
if (Test-Path $stateFile) {
    $state = Get-Content $stateFile -Encoding UTF8 | ConvertFrom-Json
} else {
    # Count total files
    $total = 0
    $dirs = @("01-flomo闪念", "02-我的幕布", "03-微信读书", "04-和AI聊天的库", "05-印象笔记", "06-飞书批量导出")
    foreach ($dir in $dirs) {
        $path = "$knowledgeBasePath\$dir"
        if (Test-Path $path) {
            $total += (Get-ChildItem $path -Recurse -File -Filter "*.md" -ErrorAction SilentlyContinue).Count
        }
    }
    
    $state = @{
        status = "running"
        currentDir = "01-flomo闪念"
        scanned = 0
        total = $total
        concepts = @{ completed = 0; target = 3000; progress = "0%" }
        quotes = @{ completed = 0; target = 5000; progress = "0%" }
        cases = @{ completed = 0; target = 2000; progress = "0%" }
        lastScanCount = 0
        totalScans = 0
        lastUpdate = (Get-Date -Format "yyyy-MM-dd HH:mm")
    }
}

# Check status
if ($state.status -ne "running") {
    Write-Output "Status: $($state.status)"
    exit 0
}

# Get current directory
$dirs = @("01-flomo闪念", "02-我的幕布", "03-微信读书", "04-和AI聊天的库", "05-印象笔记", "06-飞书批量导出")
$currentDir = $state.currentDir
$scanned = $state.scanned

# Scan files
$files = Get-ChildItem "$knowledgeBasePath\$currentDir" -Recurse -File -Filter "*.md" -ErrorAction SilentlyContinue | Select-Object -Skip $scanned -First $BatchSize

if ($files.Count -eq 0) {
    # Move to next directory
    $idx = [array]::IndexOf($dirs, $currentDir)
    if ($idx -lt $dirs.Count - 1) {
        $state.currentDir = $dirs[$idx + 1]
        $state.scanned = 0
        $files = Get-ChildItem "$knowledgeBasePath\$($dirs[$idx + 1])" -Recurse -File -Filter "*.md" -ErrorAction SilentlyContinue | Select-Object -First $BatchSize
    } else {
        $state.status = "completed"
        $state | ConvertTo-Json -Depth 10 | Set-Content $stateFile -Encoding UTF8
        Write-Output "Status: completed"
        exit 0
    }
}

$concepts = @()
$quotes = @()
$cases = @()

foreach ($file in $files) {
    try {
        $content = Get-Content $file.FullName -Encoding UTF8 -Raw
        
        # Extract concept from title
        if ($content -match "^#\s+(.+)" -and $content.Length -gt 200) {
            $title = $matches[1].Trim()
            if (Is-Concept -title $title -content $content) {
                $concepts += @{
                    title = $title
                    source = $file.Name
                    path = $file.FullName
                }
            }
        }
        
        # Extract golden quotes from sentences
        $sentences = $content -split '[。！？\n]' | Where-Object { $_.Trim().Length -gt 0 }
        foreach ($sentence in $sentences) {
            $s = $sentence.Trim()
            if (Is-GoldenQuote -sentence $s) {
                $quotes += @{
                    quote = $s
                    source = $file.Name
                    path = $file.FullName
                }
            }
        }
        
        # Check for cases
        if (Is-Case -content $content) {
            $cases += @{
                title = if ($content -match "^#\s+(.+)") { $matches[1].Trim() } else { $file.Name }
                source = $file.Name
                path = $file.FullName
            }
        }
    } catch {}
}

# Update state
$state.scanned += $files.Count
$state.remaining = $state.total - $state.scanned
$state.concepts.completed += $concepts.Count
$state.quotes.completed += $quotes.Count
$state.cases.completed += $cases.Count
$state.concepts.progress = [math]::Round($state.concepts.completed / $state.concepts.target * 100, 1).ToString() + "%"
$state.quotes.progress = [math]::Round($state.quotes.completed / $state.quotes.target * 100, 1).ToString() + "%"
$state.cases.progress = [math]::Round($state.cases.completed / $state.cases.target * 100, 1).ToString() + "%"
$state.lastScanCount = $files.Count
$state.totalScans += 1
$state.lastUpdate = Get-Date -Format "yyyy-MM-dd HH:mm"

# Save state
$state | ConvertTo-Json -Depth 10 | Set-Content $stateFile -Encoding UTF8

# Append to material files
if ($concepts.Count -gt 0) {
    $conceptText = "`n`n### 扫描提取 - $(Get-Date -Format 'yyyy-MM-dd HH:mm')`n`n"
    foreach ($c in $concepts) {
        $conceptText += "#### $($c.title)`n`n来源：$($c.source)`n`n"
    }
    Add-Content -Path $conceptFile -Value $conceptText -Encoding UTF8
}

if ($quotes.Count -gt 0) {
    $quoteText = "`n`n### 扫描提取 - $(Get-Date -Format 'yyyy-MM-dd HH:mm')`n`n"
    foreach ($q in $quotes) {
        $quoteText += "> `"$($q.quote)`"`n> —— $($q.source)`n`n"
    }
    Add-Content -Path $quoteFile -Value $quoteText -Encoding UTF8
}

# Output
Write-Output "Scanned: $($files.Count) files"
Write-Output "Concepts: +$($concepts.Count) (Total: $($state.concepts.completed))"
Write-Output "Quotes: +$($quotes.Count) (Total: $($state.quotes.completed))"
Write-Output "Cases: +$($cases.Count) (Total: $($state.cases.completed))"
Write-Output "Progress: $($state.scanned) / $($state.total) ($([math]::Round($state.scanned / $state.total * 100, 1))%)"

if ($state.scanned % 200 -eq 0 -or $state.scanned -ge $state.total) {
    Write-Output "[REPORT]"
}
