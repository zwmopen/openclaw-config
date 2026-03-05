# OpenClaw Auto Backup Script
# Auto push to GitHub at 00:00 every day
# Created: 2026-03-06

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Output "[$timestamp] $Message"
}

$repoPath = "D:\AI编程\openclaw"

Write-Log "=========================================="
Write-Log "OpenClaw Auto Backup Start"
Write-Log "=========================================="

try {
    Set-Location $repoPath
    Write-Log "Current directory: $repoPath"

    $status = git status --porcelain
    if ($status) {
        Write-Log "Detected uncommitted changes, committing..."
        git add .
        Write-Log "Added all changes to staging area"

        $commitMessage = "Auto backup: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        git commit -m $commitMessage
        Write-Log "Committed changes: $commitMessage"
    }
    else {
        Write-Log "No uncommitted changes"
    }

    Write-Log "Pulling remote changes..."
    git pull origin main
    Write-Log "Pulled remote changes"

    Write-Log "Pushing to GitHub..."
    git push origin main
    Write-Log "Push successful!"

    Write-Log "=========================================="
    Write-Log "OpenClaw Auto Backup Complete"
    Write-Log "=========================================="
}
catch {
    Write-Log "Error: $_"
    Write-Log "=========================================="
    Write-Log "OpenClaw Auto Backup Failed"
    Write-Log "=========================================="
    exit 1
}
