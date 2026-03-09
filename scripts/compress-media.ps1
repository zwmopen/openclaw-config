# 媒体文件压缩脚本
# 保持清晰度：图片质量90%，视频CRF 23

$kbPath = "D:\Program Files\Obsidian\zwm\.zwm"
$backupPath = "D:\AI编程\openclaw\media-backup"

Write-Host "=== 媒体文件压缩脚本 ===" -ForegroundColor Cyan
Write-Host "目标：$kbPath" -ForegroundColor Gray
Write-Host "备份：$backupPath" -ForegroundColor Gray

# 创建备份目录
if (-not (Test-Path $backupPath)) {
    New-Item -ItemType Directory -Path $backupPath -Force | Out-Null
    Write-Host "✅ 创建备份目录" -ForegroundColor Green
}

# 1. 压缩图片（质量90%）
Write-Host "`n=== 压缩图片 ===" -ForegroundColor Yellow
$images = Get-ChildItem $kbPath -Recurse -File -Include *.jpg,*.jpeg,*.png -ErrorAction SilentlyContinue | Where-Object { $_.Length -gt 500KB }

$totalImages = $images.Count
$currentImage = 0
$savedSpace = 0

foreach ($img in $images) {
    $currentImage++
    $originalSize = $img.Length / 1MB
    
    Write-Host "[$currentImage/$totalImages] 压缩: $($img.Name) ($([math]::Round($originalSize, 2)) MB)" -ForegroundColor Gray
    
    # 备份原文件
    $backupFile = Join-Path $backupPath $img.Name
    Copy-Item $img.FullName $backupFile -Force
    
    # 压缩（使用ffmpeg转换，质量90%）
    $tempFile = $img.FullName + ".tmp"
    ffmpeg -i $img.FullName -q:v 2 $tempFile -y -loglevel error
    
    if (Test-Path $tempFile) {
        $newSize = (Get-Item $tempFile).Length / 1MB
        $saved = $originalSize - $newSize
        $savedSpace += $saved
        
        Move-Item $tempFile $img.FullName -Force
        Write-Host "  压缩后: $([math]::Round($newSize, 2)) MB (节省 $([math]::Round($saved, 2)) MB)" -ForegroundColor Green
    }
}

Write-Host "`n✅ 图片压缩完成！节省空间: $([math]::Round($savedSpace, 2)) MB" -ForegroundColor Green

# 2. 压缩视频（H.265编码，CRF 23）
Write-Host "`n=== 压缩视频 ===" -ForegroundColor Yellow
$videos = Get-ChildItem $kbPath -Recurse -File -Include *.mp4,*.mov,*.avi,*.mkv -ErrorAction SilentlyContinue | Where-Object { $_.Length -gt 10MB }

$totalVideos = $videos.Count
$currentVideo = 0
$savedSpace = 0

foreach ($video in $videos) {
    $currentVideo++
    $originalSize = $video.Length / 1MB
    
    Write-Host "[$currentVideo/$totalVideos] 压缩: $($video.Name) ($([math]::Round($originalSize, 2)) MB)" -ForegroundColor Gray
    
    # 备份原文件
    $backupFile = Join-Path $backupPath $video.Name
    Copy-Item $video.FullName $backupFile -Force
    
    # 压缩（H.265编码，CRF 23，保持清晰度）
    $tempFile = $video.FullName + ".tmp"
    ffmpeg -i $video.FullName -c:v libx265 -crf 23 -c:a aac -b:a 128k $tempFile -y -loglevel error
    
    if (Test-Path $tempFile) {
        $newSize = (Get-Item $tempFile).Length / 1MB
        $saved = $originalSize - $newSize
        $savedSpace += $saved
        
        Move-Item $tempFile $video.FullName -Force
        Write-Host "  压缩后: $([math]::Round($newSize, 2)) MB (节省 $([math]::Round($saved, 2)) MB)" -ForegroundColor Green
    }
}

Write-Host "`n✅ 视频压缩完成！节省空间: $([math]::Round($savedSpace, 2)) MB" -ForegroundColor Green
Write-Host "`n备份文件保存在: $backupPath" -ForegroundColor Cyan
Write-Host "确认压缩无误后可以删除备份" -ForegroundColor Gray
