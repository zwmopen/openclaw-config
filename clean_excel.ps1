# Excel去重脚本

param(
    [switch]$Force,
    [switch]$Quiet
)

$BaseDir = "D:\AI编程\openclaw"
$InputFile = "$BaseDir\backup.xlsx"
$OutputFile = "$BaseDir\backup_cleaned.xlsx"

# 确保输入文件存在
if (-not (Test-Path $InputFile)) {
    Write-Host "❌ 文件不存在: $InputFile"
    exit 1
}

Write-Host "开始处理Excel文件..."
Write-Host "输入文件: $InputFile"
Write-Host "输出文件: $OutputFile"

# 使用Excel COM对象
try {
    $excel = New-Object -ComObject Excel.Application
    $workbook = $excel.Workbooks.Open($InputFile)
    $worksheet = $workbook.Worksheets.Item(1)
    
    $rowCount = $worksheet.UsedRange.Rows.Count
    Write-Host "📊 总行数: $rowCount"
    
    # 创建哈希字典
    $hashDict = @{}
    $duplicates = 0
    
    # 遍历所有行
    for ($i = 1; $i -le $rowCount; $i++) {
        $row = $worksheet.Rows.Item($i)
        
        # 获取所有单元格值
        $values = @()
        for ($j = 1; $j -le $row.Cells.Count; $j++) {
            $cellValue = $row.Cells.Item($j).Value2
            if ($cellValue -ne $null) {
                $values += $cellValue
            }
        }
        
        # 计算行哈希
        $rowString = $values -join '|'
        $rowHash = [System.BitConverter]::ToString([System.Security.Cryptography.HashAlgorithm]::MD5.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($rowString)))
        
        # 检查是否重复
        if ($hashDict.ContainsKey($rowHash)) {
            $duplicates++
            Write-Host "⚠️ 发现重复行: $i"
            
            # 标记重复行为删除
            $row.Delete()
        } else {
            $hashDict[$rowHash] = $i
        }
    }
    
    Write-Host "✅ 去重完成！删除了 $duplicates 行重复数据"
    Write-Host "📊 保留行数: $($rowCount - $duplicates)"
    
    # 保存
    $workbook.SaveAs($OutputFile)
    $workbook.Close()
    $excel.Quit()
    
    Write-Host "💾 保存到: $OutputFile"
    
} catch {
    Write-Host "❌ 处理失败: $_"
    exit 1
}

Write-Host "完成！"
