# OpenClaw 文档索引脚本

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  OpenClaw 文档索引" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$ragScript = Join-Path $scriptPath "rag_service.py"
$workspace = "D:\AI编程\openclaw"

# 检查Python
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "错误: 未找到Python" -ForegroundColor Red
    exit 1
}

# 检查依赖
Write-Host "检查依赖..." -ForegroundColor Yellow
python -c "import chromadb; import sentence_transformers" 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "安装依赖..." -ForegroundColor Yellow
    pip install chromadb sentence-transformers -q
}

# 索引文档
Write-Host "开始索引文档..." -ForegroundColor Green
Write-Host "工作目录: $workspace" -ForegroundColor White
Write-Host ""

python $ragScript --persist "D:\AI编程\openclaw\chromadb" --index $workspace

Write-Host ""
Write-Host "索引完成！" -ForegroundColor Green
Write-Host "现在可以启动RAG服务进行搜索" -ForegroundColor Yellow
