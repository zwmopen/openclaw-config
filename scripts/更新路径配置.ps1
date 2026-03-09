# 更新所有配置文件和脚本，将中文路径改为英文符号链接路径
# 目标：将 D:\openclaw 改为 D:\openclaw

Write-Host "=== 更新配置文件和脚本 ===" -ForegroundColor Cyan
Write-Host ""

$oldPath = "D:\openclaw"
$newPath = "D:\openclaw"

# 1. 更新 OpenClaw 核心配置
Write-Host "1. 更新 OpenClaw 核心配置..." -ForegroundColor Yellow
$configFile = "D:\openclaw\.openclaw\openclaw.json"
if (Test-Path $configFile) {
    $content = Get-Content $configFile -Raw -Encoding UTF8
    $newContent = $content -replace [regex]::Escape($oldPath), $newPath
    Set-Content $configFile -Value $newContent -Encoding UTF8
    Write-Host "  ✅ openclaw.json 已更新" -ForegroundColor Green
} else {
    Write-Host "  ❌ 找不到 openclaw.json" -ForegroundColor Red
}

# 2. 更新记忆文件
Write-Host ""
Write-Host "2. 更新记忆文件..." -ForegroundColor Yellow
$memoryFiles = @(
    "D:\openclaw\MEMORY.md",
    "D:\openclaw\HEARTBEAT.md",
    "D:\openclaw\SOUL.md",
    "D:\openclaw\USER.md",
    "D:\openclaw\AGENTS.md"
)

foreach ($file in $memoryFiles) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw -Encoding UTF8
        $newContent = $content -replace [regex]::Escape($oldPath), $newPath
        Set-Content $file -Value $newContent -Encoding UTF8
        Write-Host "  ✅ $(Split-Path $file -Leaf) 已更新" -ForegroundColor Green
    }
}

# 3. 更新所有脚本文件
Write-Host ""
Write-Host "3. 更新脚本文件..." -ForegroundColor Yellow
$scriptsPath = "D:\openclaw\scripts"
$scripts = Get-ChildItem $scriptsPath -Include "*.ps1","*.bat","*.cmd" -Recurse -File
$scriptCount = 0

foreach ($script in $scripts) {
    $content = Get-Content $script.FullName -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    if ($content -match [regex]::Escape($oldPath)) {
        $newContent = $content -replace [regex]::Escape($oldPath), $newPath
        Set-Content $script.FullName -Value $newContent -Encoding UTF8
        $scriptCount++
        Write-Host "  ✅ $($script.Name) 已更新" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "  共更新 $scriptCount 个脚本文件" -ForegroundColor Cyan

# 4. 更新文档文件
Write-Host ""
Write-Host "4. 更新文档文件..." -ForegroundColor Yellow
$docsPath = "D:\openclaw\docs"
$docs = Get-ChildItem $docsPath -Include "*.md" -Recurse -File
$docCount = 0

foreach ($doc in $docs) {
    $content = Get-Content $doc.FullName -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    if ($content -match [regex]::Escape($oldPath)) {
        $newContent = $content -replace [regex]::Escape($oldPath), $newPath
        Set-Content $doc.FullName -Value $newContent -Encoding UTF8
        $docCount++
    }
}

Write-Host "  共更新 $docCount 个文档文件" -ForegroundColor Cyan

# 5. 更新其他配置文件
Write-Host ""
Write-Host "5. 更新其他配置文件..." -ForegroundColor Yellow
$otherConfigs = @(
    "D:\openclaw\.openclaw\cron\jobs.json"
)

foreach ($file in $otherConfigs) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw -Encoding UTF8
        $newContent = $content -replace [regex]::Escape($oldPath), $newPath
        Set-Content $file -Value $newContent -Encoding UTF8
        Write-Host "  ✅ $(Split-Path $file -Leaf) 已更新" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "=== 完成 ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "所有配置和脚本已更新为使用英文路径：" -ForegroundColor Yellow
Write-Host "  旧路径：$oldPath" -ForegroundColor Red
Write-Host "  新路径：$newPath" -ForegroundColor Green
Write-Host ""
Write-Host "按任意键退出..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

