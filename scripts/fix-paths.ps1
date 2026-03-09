# 批量替换 D:\AICode\openclaw\ �?D:\AICode\openclaw\
# 运行时间�?026-03-09

Write-Host "Starting path replacement..." -ForegroundColor Cyan

$files = Get-ChildItem -Path "D:\AICode\openclaw" -Recurse -Include "*.ps1","*.md","*.json","*.bat","*.cmd" -ErrorAction SilentlyContinue
$count = 0
$total = $files.Count

Write-Host "Found $total files to check" -ForegroundColor Yellow

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
    if ($content -match 'D:\\openclaw\\') {
        $newContent = $content -replace 'D:\\openclaw\\', 'D:\AICode\openclaw\'
        Set-Content -Path $file.FullName -Value $newContent -ErrorAction SilentlyContinue
        $count++
        Write-Host "Updated: $($file.Name)" -ForegroundColor Green
    }
}

Write-Host "`nDone! Replaced in $count files" -ForegroundColor Cyan

# 检查定时任�?Write-Host "`nChecking scheduled tasks..." -ForegroundColor Cyan
$tasks = Get-ScheduledTask | Where-Object { $_.TaskPath -like "*OpenClaw*" -or $_.TaskName -like "*OpenClaw*" }
$tasks | Select-Object TaskName, State | Format-Table -AutoSize

# 检查软链接
Write-Host "`nChecking symlink..." -ForegroundColor Cyan
$link = Get-Item "D:\Program Files\Obsidian\zwm\.zwm\OpenClaw配置" -ErrorAction SilentlyContinue
if ($link) {
    Write-Host "Symlink status: $($link.LinkType)" -ForegroundColor Green
    Write-Host "Target: $($link.Target)" -ForegroundColor Green
} else {
    Write-Host "Symlink not found" -ForegroundColor Yellow
}

Write-Host "`nAll done!" -ForegroundColor Cyan

