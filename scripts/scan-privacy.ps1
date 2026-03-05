# privacy-scan.ps1
$results = @()
$paths = @('C:\Users\z', 'D:\')

# Scan for sensitive file patterns
$filePatterns = @(
    '*.env*', '*password*', '*secret*', '*private*', 
    '*.pem', '*.key', '*.p12', '*.pfx',
    '*token*', '*credential*', '*auth*'
)

foreach ($basePath in $paths) {
    Write-Host "Scanning $basePath ..."
    foreach ($pattern in $filePatterns) {
        Get-ChildItem -Path $basePath -Recurse -Filter $pattern -File -ErrorAction SilentlyContinue | 
        Where-Object { 
            $_.FullName -notlike '*node_modules*' -and 
            $_.FullName -notlike '*AppData*' -and
            $_.FullName -notlike '*.git*' -and
            $_.FullName -notlike '*Windows*'
        } | ForEach-Object {
            $results += [PSCustomObject]@{
                File = $_.Name
                Path = $_.DirectoryName
                SizeKB = [math]::Round($_.Length / 1KB, 1)
            }
        }
    }
}

Write-Host "`n========== RESULTS =========="
$results | Sort-Object File | Format-Table -AutoSize

Write-Host "`nTotal: $($results.Count) files found"
