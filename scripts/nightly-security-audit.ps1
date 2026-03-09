# OpenClaw Nightly Security Audit Script v2.7 (Windows)
# Run daily at 03:00
# Output: Feishu message + local report

param(
    [string]$OutputPath = "D:\openclaw\logs\security-reports"
)

$ErrorActionPreference = "Continue"
$reportDate = Get-Date -Format "yyyy-MM-dd"
$reportTime = Get-Date -Format "HH:mm:ss"
$reportFile = Join-Path $OutputPath "report-$reportDate.txt"

# Ensure output directory exists
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

# Initialize report
$reportHeader = @"
========================================
OpenClaw Daily Security Audit Report
Date: $reportDate
Time: $reportTime
========================================

"@

# Results collection
$results = @()

# 1. OpenClaw Config Audit
function Test-OpenClawConfig {
    $configPath = "D:\openclaw\.openclaw\openclaw.json"
    $configPathAlt = "C:\Users\z\.openclaw\openclaw.json"
    if (Test-Path $configPath) {
        $configPath = $configPath
    } elseif (Test-Path $configPathAlt) {
        $configPath = $configPathAlt
    } else {
        return "ERROR: Config file not found"
    }
    if (Test-Path $configPath) {
        # Check permissions
        $acl = Get-Acl $configPath
        $access = $acl.AccessToString
        if ($access -match "NT AUTHORITY\\Authenticated Users") {
            return "WARNING: Config file permissions too wide"
        }
        # Check hash
        $baselinePath = "D:\openclaw\.openclaw\.config-baseline.sha256"
        if (Test-Path $baselinePath) {
            $currentHash = (Get-FileHash $configPath -Algorithm SHA256).Hash.ToLower()
            $baselineContent = Get-Content $baselinePath
            if ($baselineContent -match $currentHash) {
                return "OK: Config hash verified, permissions compliant"
            } else {
                return "WARNING: Config hash mismatch, file may be tampered"
            }
        }
        return "OK: Config exists, permissions compliant"
    }
    return "ERROR: Config file not found"
}

# 2. Network Security
function Test-NetworkSecurity {
    $listening = netstat -ano | Select-String "LISTENING" | Select-String ":18789"
    if ($listening -match "0\.0\.0\.0") {
        return "WARNING: Port 18789 exposed to public!"
    } elseif ($listening -match "127\.0\.0\.1") {
        return "OK: Port 18789 only listening on localhost"
    }
    return "INFO: Port 18789 not listening"
}

# 3. Directory Changes
function Test-DirectoryChanges {
    $changes = @()
    $paths = @(
        "D:\openclaw\.openclaw",
        "C:\Users\z\.ssh"
    )
    foreach ($path in $paths) {
        if (Test-Path $path) {
            $recentFiles = Get-ChildItem $path -Recurse -File -ErrorAction SilentlyContinue | 
                Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-1) }
            if ($recentFiles) {
                $changes += "  - $path : $($recentFiles.Count) files changed"
            }
        }
    }
    if ($changes.Count -eq 0) {
        return "OK: No suspicious file changes"
    }
    return "INFO: Recent 24h changes:`n$($changes -join "`n")"
}

# 4. Scheduled Tasks
function Test-ScheduledTasks {
    $tasks = Get-ScheduledTask | Where-Object { 
        $_.State -eq "Ready" -and 
        $_.TaskPath -notmatch "Microsoft" 
    } | Select-Object -First 10 TaskName
    if ($tasks) {
        return "INFO: Non-Microsoft tasks: $($tasks.TaskName -join ', ')"
    }
    return "OK: No suspicious system tasks"
}

# 5. Disk Usage
function Test-DiskUsage {
    $disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'"
    $usedPercent = [math]::Round(($disk.Size - $disk.FreeSpace) / $disk.Size * 100, 1)
    if ($usedPercent -gt 85) {
        return "WARNING: C drive usage ${usedPercent}%, above 85% threshold"
    }
    return "OK: C drive usage ${usedPercent}%, normal"
}

# 6. Credential Leak Scan
function Test-CredentialLeak {
    $leaked = @()
    $memoryPath = "D:\openclaw\.openclaw\workspace\memory"
    if (Test-Path $memoryPath) {
        $files = Get-ChildItem $memoryPath -Filter "*.md" -Recurse
        foreach ($file in $files) {
            $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
            if ($content -match "(?i)(private\s*key|-----BEGIN.*PRIVATE KEY-----)") {
                $leaked += "  - $($file.Name) (private key)"
            }
        }
    }
    if ($leaked.Count -eq 0) {
        return "OK: No plaintext private keys found in memory"
    }
    return "WARNING: Possible credential leak:`n$($leaked -join "`n")"
}

# Execute all checks
$results += "1. Platform Audit: $(Test-OpenClawConfig)"
$results += "2. Network: $(Test-NetworkSecurity)"
$results += "3. Dir Changes: $(Test-DirectoryChanges)"
$results += "4. System Tasks: $(Test-ScheduledTasks)"
$results += "5. Disk Usage: $(Test-DiskUsage)"
$results += "6. Credential Scan: $(Test-CredentialLeak)"

# Generate report
$fullReport = $reportHeader + ($results -join "`n") + "`n`n========================================`nReport saved: $reportFile`n========================================"

# Save report
$fullReport | Out-File $reportFile -Encoding UTF8

# Output to console
Write-Output $fullReport

