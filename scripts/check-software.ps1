# 检查磁盘空间
Write-Host "=== 磁盘空间 ==="
Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Name -eq 'C' -or $_.Name -eq 'D' } | ForEach-Object {
    $used = [math]::Round($_.Used/1GB, 2)
    $free = [math]::Round($_.Free/1GB, 2)
    $total = [math]::Round(($_.Used+$_.Free)/1GB, 2)
    Write-Host "$($_.Name)盘: 已用 ${used}GB / 总共 ${total}GB (剩余 ${free}GB)"
}

# 检查Program Files文件夹大小
Write-Host "`n=== C盘 Program Files 大软件 (>100MB) ==="
Get-ChildItem "C:\Program Files" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $size = (Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1MB
    if($size -gt 100) {
        Write-Host ("{0:N0} MB - {1}" -f $size, $_.Name)
    }
}

Write-Host "`n=== C盘 Program Files (x86) 大软件 (>100MB) ==="
Get-ChildItem "C:\Program Files (x86)" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $size = (Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1MB
    if($size -gt 100) {
        Write-Host ("{0:N0} MB - {1}" -f $size, $_.Name)
    }
}

Write-Host "`n=== D盘 Program Files 大软件 (>100MB) ==="
if(Test-Path "D:\Program Files") {
    Get-ChildItem "D:\Program Files" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $size = (Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1MB
        if($size -gt 100) {
            Write-Host ("{0:N0} MB - {1}" -f $size, $_.Name)
        }
    }
}

# 检查用户文件夹大小
Write-Host "`n=== 用户文件夹大小 ==="
$userFolders = @("Desktop", "Documents", "Downloads", "AppData\Local")
foreach($folder in $userFolders) {
    $path = "C:\Users\z\$folder"
    if(Test-Path $path) {
        $size = (Get-ChildItem $path -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1MB
        Write-Host ("{0:N0} MB - {1}" -f $size, $folder)
    }
}
