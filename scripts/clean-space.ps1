<#
.SYNOPSIS
    Clean Trae cache and free disk space
#>

Write-Host "=== Disk Space Analysis ===" -ForegroundColor Cyan

# Get current disk space
$drive = Get-PSDrive C
$freeGB = [math]::Round($drive.Free / 1GB, 2)
Write-Host "C: Drive Free Space: $freeGB GB" -ForegroundColor $(if ($freeGB -lt 5) { "Red" } else { "Green" })

# Analyze Trae directories
$traeRoot = "C:\Users\z\.trae-cn"
$dirs = @('866879093639326', 'agent-extensions', 'binaries', 'extensions', 'sdks', 'skills', 'tools', 'worktrees')

Write-Host "`n=== Trae Directory Sizes ===" -ForegroundColor Cyan
$totalTrae = 0
foreach ($d in $dirs) {
    $path = Join-Path $traeRoot $d
    if (Test-Path $path) {
        $size = (Get-ChildItem $path -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        $sizeMB = [math]::Round($size / 1MB, 1)
        Write-Host "  $d : $sizeMB MB"
        $totalTrae += $size
    }
}
Write-Host "`nTotal Trae: $([math]::Round($totalTrae/1GB, 2)) GB" -ForegroundColor Yellow

# Clean temp files
Write-Host "`n=== Cleaning Temp Files ===" -ForegroundColor Cyan
$tempPath = "$env:TEMP"
$tempSize = (Get-ChildItem $tempPath -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
Write-Host "Temp folder size: $([math]::Round($tempSize/1MB, 1)) MB"

# Clean cache
$cachePath = "C:\Users\z\.cache"
if (Test-Path $cachePath) {
    $cacheSize = (Get-ChildItem $cachePath -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    Write-Host "Cache folder size: $([math]::Round($cacheSize/1MB, 1)) MB"
}

# Clean npm cache
Write-Host "`n=== Cleaning npm cache ===" -ForegroundColor Cyan
$npmCache = npm cache ls 2>$null
if ($npmCache) {
    npm cache clean --force 2>$null
    Write-Host "npm cache cleaned" -ForegroundColor Green
}

# Summary
Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host "Space that can be freed:"
Write-Host "  - Temp files: ~$([math]::Round($tempSize/1MB, 0)) MB"
Write-Host "  - Cache: ~$([math]::Round($cacheSize/1MB, 0)) MB"
Write-Host ""
Write-Host "To clean temp and cache, run:" -ForegroundColor Yellow
Write-Host "  Remove-Item '$tempPath\*' -Recurse -Force -ErrorAction SilentlyContinue" -ForegroundColor Gray
Write-Host "  Remove-Item '$cachePath\*' -Recurse -Force -ErrorAction SilentlyContinue" -ForegroundColor Gray
