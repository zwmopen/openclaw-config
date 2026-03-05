# 批量笔记梳理脚本
# 频率控制：每分钟最多6次（安全范围，RPM=10限制）

$notesRoot = "D:\Program Files\Obsidian\zwm\.zwm\个人知识库\印象笔记"
$progressFile = "D:\Program Files\Obsidian\zwm\.zwm\OpenClaw\梳理进度.md"
$logFile = "D:\AI编程\openclaw\logs\note-organize.log"

# 创建日志目录
$logDir = Split-Path $logFile -Parent
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

# 待处理文件夹
$folders = @(
  "1-1收集箱（历史欠账）",
  "2019日记", 
  "2020日记",
  "2021日记",
  "文章收藏"
)

function Write-Log {
  param([string]$message)
  $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  $logLine = "[$timestamp] $message"
  Add-Content -Path $logFile -Value $logLine
  Write-Host $logLine
}

function Get-PendingNotes {
  param([string[]]$folders)
  
  $pending = @()
  foreach ($folder in $folders) {
    $folderPath = Join-Path $notesRoot $folder
    if (Test-Path $folderPath) {
      $files = Get-ChildItem -Path $folderPath -Filter "*.md" -Recurse | 
               Where-Object { $_.Name -notlike "*已梳理*" } |
               Select-Object -First 100  # 每次最多处理100个
      $pending += $files
    }
  }
  return $pending
}

# 主循环
$batchCount = 0
$totalProcessed = 0
$startTime = Get-Date
$hourlyReport = $startTime

Write-Log "=== 开始批量梳理 ==="
Write-Log "开始时间: $($startTime.ToString('yyyy-MM-dd HH:mm:ss'))"

while ($true) {
  # 获取待处理笔记
  $pendingNotes = Get-PendingNotes -folders $folders
  
  if ($pendingNotes.Count -eq 0) {
    Write-Log "所有笔记处理完成！"
    break
  }
  
  Write-Log "本轮待处理: $($pendingNotes.Count) 个文件"
  
  foreach ($note in $pendingNotes) {
    $batchCount++
    $totalProcessed++
    
    # 检查是否需要跳过
    $content = Get-Content $note.FullName -Raw -ErrorAction SilentlyContinue
    
    if (-not $content) {
      Write-Log "跳过空文件: $($note.Name)"
      continue
    }
    
    # 跳过太短或太长
    $charCount = $content.Length
    if ($charCount -lt 100) {
      Write-Log "跳过短文件($charCount字): $($note.Name)"
      continue
    }
    if ($charCount -gt 5000) {
      Write-Log "跳过长文件($charCount字): $($note.Name)"
      continue
    }
    
    # 跳过纯图片
    if ($content -match '!\[.*\]\(.*\)' -and $content -replace '!\[.*\]\(.*\)', '' -replace '\s', '' -eq '') {
      Write-Log "跳过纯图片: $($note.Name)"
      continue
    }
    
    # 创建待处理标记
    $queueFile = "D:\AI编程\openclaw\logs\pending_notes.txt"
    Add-Content -Path $queueFile -Value $note.FullName
    
    # 频率控制：每处理6个文件等待10秒
    if ($batchCount % 6 -eq 0) {
      Write-Log "已处理 $totalProcessed 个，等待10秒..."
      Start-Sleep -Seconds 10
    }
    
    # 每小时报告进度
    $now = Get-Date
    if (($now - $hourlyReport).TotalMinutes -ge 60) {
      $elapsed = $now - $startTime
      Write-Log "=== 每小时进度报告 ==="
      Write-Log "运行时间: $($elapsed.TotalHours.ToString('F1')) 小时"
      Write-Log "已处理: $totalProcessed 个文件"
      Write-Log "剩余待处理: $($pendingNotes.Count) 个"
      
      # 更新进度文件
      $hourlyReport = $now
    }
  }
  
  # 等待下一轮
  Write-Log "本轮完成，等待30秒后继续..."
  Start-Sleep -Seconds 30
}

$endTime = Get-Date
$totalTime = $endTime - $startTime
Write-Log "=== 批量梳理完成 ==="
Write-Log "总处理: $totalProcessed 个文件"
Write-Log "总时间: $($totalTime.TotalHours.ToString('F1')) 小时"
