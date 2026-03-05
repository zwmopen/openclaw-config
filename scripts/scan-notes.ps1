$targetPath = 'D:\Program Files\Obsidian\zwm\.zwm\个人知识库\印象笔记\1-1收集箱（历史欠账）'
$files = Get-ChildItem -Path $targetPath -Filter '*.md' -Recurse
$total = $files.Count
$processed = ($files | Where-Object { $_.Name -match '已梳理' }).Count

$candidates = @()
foreach ($f in $files) {
    if ($f.Name -notmatch '已梳理' -and $f.Name -notmatch '2020-' -and $f.Name -notmatch '21天') {
        $content = Get-Content $f.FullName -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
        if ($content -and $content.Length -ge 2000 -and $content.Length -le 15000) {
            $candidates += [PSCustomObject]@{Name=$f.Name; FullName=$f.FullName; Length=$content.Length}
        }
    }
}

$rate = [math]::Round($processed / $total * 100, 1)
Write-Host "Total: $total"
Write-Host "Processed: $processed"
Write-Host "Pending: $($candidates.Count)"
Write-Host "Rate: $rate%"
Write-Host '---NEXT10---'
$sorted = $candidates | Sort-Object Length -Descending
$sorted | Select-Object -First 10 | ForEach-Object { 
    Write-Host "$($_.Name|||SPLIT|||$($_.FullName)|||SPLIT|||$($_.Length))"
}
