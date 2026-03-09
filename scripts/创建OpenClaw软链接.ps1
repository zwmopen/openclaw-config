# 创建OpenClaw工作目录软链接
# 需要以管理员权限运行

$openclawPath = "D:\AI编程\openclaw"
$obsidianPath = "D:\Program Files\Obsidian\zwm\.zwm\OpenClaw工作目录"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "创建OpenClaw工作目录软链接" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查是否以管理员权限运行
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "❌ 需要以管理员权限运行！" -ForegroundColor Red
    Write-Host ""
    Write-Host "请右键此脚本，选择'以管理员身份运行'" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "按Enter键退出"
    exit
}

# 检查OpenClaw工作目录是否存在
if (-not (Test-Path $openclawPath)) {
    Write-Host "❌ OpenClaw工作目录不存在：$openclawPath" -ForegroundColor Red
    Read-Host "按Enter键退出"
    exit
}

# 检查软链接是否已存在
if (Test-Path $obsidianPath) {
    Write-Host "⚠️  软链接已存在，删除旧链接..." -ForegroundColor Yellow
    Remove-Item $obsidianPath -Force -Recurse
}

# 创建软链接
Write-Host "📦 创建软链接..." -ForegroundColor Green
New-Item -Path $obsidianPath -ItemType SymbolicLink -Value $openclawPath -Force | Out-Null

# 验证
if (Test-Path $obsidianPath) {
    Write-Host ""
    Write-Host "✅ 软链接创建成功！" -ForegroundColor Green
    Write-Host ""
    Write-Host "📁 软链接位置：$obsidianPath" -ForegroundColor Cyan
    Write-Host "🎯 指向目录：$openclawPath" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "现在可以在Obsidian中直接访问OpenClaw工作目录了！" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "❌ 软链接创建失败！" -ForegroundColor Red
}

Write-Host ""
Read-Host "按Enter键退出"
