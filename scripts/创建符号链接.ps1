# 创建符号链接（需要管理员权限）
# 将 D:\openclaw 指向 D:\openclaw

Write-Host "=== 创建符号链接 ===" -ForegroundColor Cyan
Write-Host ""

# 检查目标目录是否存在
$targetPath = "D:\openclaw"
$linkPath = "D:\openclaw"

if (-not (Test-Path $targetPath)) {
    Write-Host "? 目标目录不存在：$targetPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "按任意键退出..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# 检查符号链接是否已存在
if (Test-Path $linkPath) {
    $item = Get-Item $linkPath
    if ($item.LinkType -eq "SymbolicLink") {
        Write-Host "?? 符号链接已存在" -ForegroundColor Yellow
        Write-Host "  当前指向：$($item.Target)" -ForegroundColor Cyan
        
        if ($item.Target -eq $targetPath) {
            Write-Host "  ? 已指向正确路径，无需重新创建" -ForegroundColor Green
        } else {
            Write-Host "  ?? 指向不同路径，需要先删除" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "是否删除并重新创建？(Y/N)" -ForegroundColor Yellow
            $confirm = Read-Host
            if ($confirm -eq "Y" -or $confirm -eq "y") {
                Remove-Item $linkPath -Force
                Write-Host "  已删除旧链接" -ForegroundColor Green
            } else {
                Write-Host "  取消操作" -ForegroundColor Red
                exit 0
            }
        }
    } else {
        Write-Host "? $linkPath 已存在且不是符号链接" -ForegroundColor Red
        Write-Host "  请手动处理或选择其他路径" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "按任意键退出..." -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }
}

# 创建符号链接
if (-not (Test-Path $linkPath)) {
    Write-Host "创建符号链接：" -ForegroundColor Yellow
    Write-Host "  源路径：$linkPath" -ForegroundColor Cyan
    Write-Host "  目标路径：$targetPath" -ForegroundColor Cyan
    Write-Host ""

    try {
        New-Item -ItemType SymbolicLink -Path $linkPath -Target $targetPath | Out-Null
        Write-Host "? 符号链接创建成功！" -ForegroundColor Green
        
        # 验证
        $item = Get-Item $linkPath
        Write-Host ""
        Write-Host "验证：" -ForegroundColor Yellow
        Write-Host "  链接类型：$($item.LinkType)" -ForegroundColor Green
        Write-Host "  指向路径：$($item.Target)" -ForegroundColor Green
        
    } catch {
        Write-Host "? 创建失败：$_" -ForegroundColor Red
        Write-Host ""
        Write-Host "可能原因：" -ForegroundColor Yellow
        Write-Host "  1. 需要管理员权限" -ForegroundColor Yellow
        Write-Host "  2. 路径不存在" -ForegroundColor Yellow
        Write-Host "  3. 权限不足" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=== 完成 ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "现在你可以使用以下路径：" -ForegroundColor Yellow
Write-Host "  D:\AICode\openclaw\scripts\xxx.ps1" -ForegroundColor Green
Write-Host "  D:\AICode\openclaw\.openclaw\openclaw.json" -ForegroundColor Green
Write-Host ""
Write-Host "这和以下路径完全等价：" -ForegroundColor Yellow
Write-Host "  D:\AICode\openclaw\scripts\xxx.ps1" -ForegroundColor Cyan
Write-Host "  D:\AICode\openclaw\.openclaw\openclaw.json" -ForegroundColor Cyan
Write-Host ""
Write-Host "按任意键退出..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")


