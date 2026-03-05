# 分析AppData\Local文件夹
Write-Host "=== AppData\Local 大文件夹 (>100MB) ==="
Get-ChildItem "C:\Users\z\AppData\Local" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $size = (Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1MB
    if($size -gt 100) {
        Write-Output ("{0:N0} MB - {1}" -f $size, $_.Name)
    }
} | Sort-Object

Write-Host "`n=== Temp 文件夹大小 ==="
$tempSize = (Get-ChildItem "C:\Users\z\AppData\Local\Temp" -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1MB
Write-Output ("{0:N0} MB - Temp (临时文件，可安全删除)" -f $tempSize)
