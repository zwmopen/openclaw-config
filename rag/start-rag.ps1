# OpenClaw RAG 服务启动脚本

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  OpenClaw RAG 服务" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$ragScript = Join-Path $scriptPath "rag_service.py"

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

# 启动服务
Write-Host "启动RAG服务..." -ForegroundColor Green
Write-Host ""
Write-Host "API端点:" -ForegroundColor Yellow
Write-Host "  GET  /health - 健康检查" -ForegroundColor White
Write-Host "  GET  /stats - 统计信息" -ForegroundColor White
Write-Host "  GET  /search?q=查询 - 搜索文档" -ForegroundColor White
Write-Host "  GET  /context?q=查询 - 获取上下文" -ForegroundColor White
Write-Host "  POST /index - 索引文件或目录" -ForegroundColor White
Write-Host ""

python $ragScript --port 18790 --persist "D:\AI编程\openclaw\chromadb"
