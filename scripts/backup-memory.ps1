# OpenClaw Memory Backup Script
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$BackupDir = "C:\Users\z\openclaw-backups"
if (-not (Test-Path $BackupDir)) { New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null }

$Date = Get-Date -Format "yyyyMMdd_HHmm"
$TempDir = "$env:TEMP\ocbackup_$Date"
if (Test-Path $TempDir) { Remove-Item $TempDir -Recurse -Force }
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

$OpenClawDir = "D:\openclaw"
$mdFiles = [System.IO.Directory]::GetFiles($OpenClawDir, "*.md")

Write-Host "Found $($mdFiles.Count) files"

$fileCount = 0
foreach ($file in $mdFiles) {
    $fileName = [System.IO.Path]::GetFileName($file)
    if ($fileName -like "temp_*") { continue }
    $dest = Join-Path $TempDir $fileName
    [System.IO.File]::Copy($file, $dest, $true)
    Write-Host "  $fileName"
    $fileCount++
}

$memoryPath = "$OpenClawDir\memory"
if (Test-Path $memoryPath) {
    Copy-Item -Path $memoryPath -Destination "$TempDir\memory" -Recurse -Force
}

$BackupFile = "$BackupDir\openclaw-memory-$Date.zip"
if (Test-Path $BackupFile) { Remove-Item $BackupFile -Force }
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($TempDir, $BackupFile)

$FileSize = (Get-Item $BackupFile).Length / 1KB
Write-Host ""
Write-Host "Backup complete: $BackupFile" -ForegroundColor Green
Write-Host "Size: $([math]::Round($FileSize, 2)) KB ($fileCount files)"

Remove-Item $TempDir -Recurse -Force -ErrorAction SilentlyContinue

