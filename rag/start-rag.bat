@echo off
chcp 65001 >nul
echo ========================================
echo   OpenClaw RAG 服务
echo ========================================
echo.

cd /d "%~dp0"

REM 检查Python
python --version >nul 2>&1
if errorlevel 1 (
    echo 错误: 未找到Python
    pause
    exit /b 1
)

REM 检查ChromaDB
python -c "import chromadb" >nul 2>&1
if errorlevel 1 (
    echo 正在安装依赖...
    pip install chromadb -q
)

echo 启动RAG服务...
echo.
echo API端点:
echo   GET  /health - 健康检查
echo   GET  /stats - 统计信息
echo   GET  /search?q=查询 - 搜索文档
echo   GET  /context?q=查询 - 获取上下文
echo   POST /index - 索引目录
echo.

python rag_service_full.py --port 18790 --persist "../chromadb" --embedding-type siliconflow --embedding-model "BAAI/bge-large-zh-v1.5" --api-key "sk-hyaakxkupozeqeisekcvnvterzifvgcjconbghtmxgrjufke"

pause
