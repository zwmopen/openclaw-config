"""
OpenClaw RAG 服务 - 向量检索增强生成
基于ChromaDB实现智能文档检索
"""

import os
import json
import hashlib
from pathlib import Path
from typing import List, Dict, Optional
from datetime import datetime

# 尝试导入依赖
try:
    import chromadb
    from chromadb.config import Settings
    CHROMADB_AVAILABLE = True
except ImportError:
    CHROMADB_AVAILABLE = False
    print("警告: ChromaDB未安装，请运行: pip install chromadb")

try:
    from sentence_transformers import SentenceTransformer
    EMBEDDING_AVAILABLE = True
except ImportError:
    EMBEDDING_AVAILABLE = False
    print("警告: sentence-transformers未安装，请运行: pip install sentence-transformers")


class OpenClawRAG:
    """OpenClaw RAG服务类"""
    
    def __init__(
        self,
        persist_directory: str = "./chromadb",
        embedding_model: str = "paraphrase-multilingual-MiniLM-L12-v2",
        chunk_size: int = 1000,
        chunk_overlap: int = 200
    ):
        """
        初始化RAG服务
        
        Args:
            persist_directory: ChromaDB持久化目录
            embedding_model: 嵌入模型名称
            chunk_size: 文本分块大小
            chunk_overlap: 分块重叠大小
        """
        self.persist_directory = persist_directory
        self.chunk_size = chunk_size
        self.chunk_overlap = chunk_overlap
        
        # 检查依赖
        if not CHROMADB_AVAILABLE or not EMBEDDING_AVAILABLE:
            raise RuntimeError("请先安装依赖: pip install chromadb sentence-transformers")
        
        # 初始化嵌入模型（使用多语言模型，支持中文）
        print(f"正在加载嵌入模型: {embedding_model}")
        self.embedding_model = SentenceTransformer(embedding_model)
        
        # 初始化ChromaDB
        print(f"正在初始化ChromaDB: {persist_directory}")
        self.client = chromadb.PersistentClient(path=persist_directory)
        self.collection = self.client.get_or_create_collection(
            name="openclaw_documents",
            metadata={"description": "OpenClaw文档向量库"}
        )
        
        print(f"RAG服务初始化完成，当前文档数: {self.collection.count()}")
    
    def _chunk_text(self, text: str) -> List[str]:
        """
        将文本分割成块
        
        Args:
            text: 原始文本
            
        Returns:
            文本块列表
        """
        if len(text) <= self.chunk_size:
            return [text]
        
        chunks = []
        start = 0
        while start < len(text):
            end = start + self.chunk_size
            chunk = text[start:end]
            chunks.append(chunk)
            start = end - self.chunk_overlap
        
        return chunks
    
    def _get_file_hash(self, file_path: str) -> str:
        """计算文件哈希值"""
        with open(file_path, 'rb') as f:
            return hashlib.md5(f.read()).hexdigest()
    
    def index_file(self, file_path: str, metadata: Optional[Dict] = None) -> int:
        """
        索引单个文件
        
        Args:
            file_path: 文件路径
            metadata: 元数据
            
        Returns:
            索引的文档块数量
        """
        if not os.path.exists(file_path):
            print(f"文件不存在: {file_path}")
            return 0
        
        # 读取文件内容
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
        except Exception as e:
            print(f"读取文件失败 {file_path}: {e}")
            return 0
        
        # 分块
        chunks = self._chunk_text(content)
        
        # 准备元数据
        if metadata is None:
            metadata = {}
        
        file_hash = self._get_file_hash(file_path)
        base_metadata = {
            "file_path": file_path,
            "file_name": os.path.basename(file_path),
            "file_hash": file_hash,
            "indexed_at": datetime.now().isoformat()
        }
        base_metadata.update(metadata)
        
        # 生成嵌入向量
        embeddings = self.embedding_model.encode(chunks).tolist()
        
        # 生成ID
        ids = [f"{file_hash}_{i}" for i in range(len(chunks))]
        
        # 准备元数据列表
        metadatas = [{**base_metadata, "chunk_index": i} for i in range(len(chunks))]
        
        # 添加到向量库
        self.collection.add(
            ids=ids,
            embeddings=embeddings,
            documents=chunks,
            metadatas=metadatas
        )
        
        print(f"已索引文件: {file_path} ({len(chunks)} 个块)")
        return len(chunks)
    
    def index_directory(
        self,
        directory: str,
        extensions: List[str] = [".md", ".txt", ".json"],
        exclude_dirs: List[str] = ["node_modules", ".git", "__pycache__", "chromadb"]
    ) -> Dict:
        """
        索引整个目录
        
        Args:
            directory: 目录路径
            extensions: 要索引的文件扩展名
            exclude_dirs: 排除的目录
            
        Returns:
            索引统计信息
        """
        stats = {
            "total_files": 0,
            "indexed_files": 0,
            "total_chunks": 0,
            "errors": []
        }
        
        for root, dirs, files in os.walk(directory):
            # 排除指定目录
            dirs[:] = [d for d in dirs if d not in exclude_dirs]
            
            for file in files:
                # 检查扩展名
                ext = os.path.splitext(file)[1].lower()
                if ext not in extensions:
                    continue
                
                stats["total_files"] += 1
                file_path = os.path.join(root, file)
                
                try:
                    chunks = self.index_file(file_path, {
                        "directory": directory,
                        "relative_path": os.path.relpath(file_path, directory)
                    })
                    if chunks > 0:
                        stats["indexed_files"] += 1
                        stats["total_chunks"] += chunks
                except Exception as e:
                    stats["errors"].append(f"{file_path}: {str(e)}")
        
        print(f"\n索引完成:")
        print(f"  总文件数: {stats['total_files']}")
        print(f"  已索引文件: {stats['indexed_files']}")
        print(f"  总文档块: {stats['total_chunks']}")
        if stats["errors"]:
            print(f"  错误数: {len(stats['errors'])}")
        
        return stats
    
    def search(self, query: str, top_k: int = 5) -> List[Dict]:
        """
        搜索相关文档
        
        Args:
            query: 查询文本
            top_k: 返回结果数量
            
        Returns:
            搜索结果列表
        """
        # 生成查询向量
        query_embedding = self.embedding_model.encode([query]).tolist()
        
        # 搜索
        results = self.collection.query(
            query_embeddings=query_embedding,
            n_results=top_k,
            include=["documents", "metadatas", "distances"]
        )
        
        # 格式化结果
        formatted_results = []
        for i in range(len(results["ids"][0])):
            formatted_results.append({
                "id": results["ids"][0][i],
                "document": results["documents"][0][i],
                "metadata": results["metadatas"][0][i],
                "distance": results["distances"][0][i],
                "relevance": 1 - results["distances"][0][i]  # 转换为相似度
            })
        
        return formatted_results
    
    def get_context(self, query: str, top_k: int = 5, max_tokens: int = 4000) -> str:
        """
        获取查询上下文（用于LLM输入）
        
        Args:
            query: 查询文本
            top_k: 检索结果数量
            max_tokens: 最大token数（近似）
            
        Returns:
            格式化的上下文字符串
        """
        results = self.search(query, top_k)
        
        context_parts = []
        current_length = 0
        
        for i, result in enumerate(results):
            doc = result["document"]
            source = result["metadata"].get("file_name", "未知来源")
            relevance = result["relevance"]
            
            # 格式化上下文
            part = f"\n[文档 {i+1}] (相关度: {relevance:.2f}, 来源: {source})\n{doc}\n"
            
            # 检查长度限制
            if current_length + len(part) > max_tokens * 4:  # 粗略估计
                break
            
            context_parts.append(part)
            current_length += len(part)
        
        context = "".join(context_parts)
        return f"以下是相关的文档内容:\n{context}"
    
    def clear(self):
        """清空向量库"""
        # 删除并重新创建集合
        self.client.delete_collection("openclaw_documents")
        self.collection = self.client.get_or_create_collection(
            name="openclaw_documents",
            metadata={"description": "OpenClaw文档向量库"}
        )
        print("向量库已清空")
    
    def get_stats(self) -> Dict:
        """获取统计信息"""
        return {
            "total_documents": self.collection.count(),
            "persist_directory": self.persist_directory,
            "embedding_model": self.embedding_model.get_sentence_embedding_dimension()
        }


# HTTP服务封装
def create_http_server(rag: OpenClawRAG, port: int = 18790):
    """
    创建HTTP API服务
    
    Args:
        rag: RAG实例
        port: 服务端口
    """
    from http.server import HTTPServer, BaseHTTPRequestHandler
    import urllib.parse
    import json
    
    class RAGHandler(BaseHTTPRequestHandler):
        def _send_json(self, data, status=200):
            self.send_response(status)
            self.send_header('Content-Type', 'application/json; charset=utf-8')
            self.end_headers()
            self.wfile.write(json.dumps(data, ensure_ascii=False).encode('utf-8'))
        
        def do_GET(self):
            parsed = urllib.parse.urlparse(self.path)
            
            if parsed.path == '/health':
                self._send_json({"status": "ok", "service": "OpenClaw RAG"})
            
            elif parsed.path == '/stats':
                self._send_json(rag.get_stats())
            
            elif parsed.path == '/search':
                params = urllib.parse.parse_qs(parsed.query)
                query = params.get('q', [''])[0]
                top_k = int(params.get('k', ['5'])[0])
                
                if not query:
                    self._send_json({"error": "缺少查询参数 q"}, 400)
                    return
                
                results = rag.search(query, top_k)
                self._send_json({"query": query, "results": results})
            
            elif parsed.path == '/context':
                params = urllib.parse.parse_qs(parsed.query)
                query = params.get('q', [''])[0]
                top_k = int(params.get('k', ['5'])[0])
                max_tokens = int(params.get('max_tokens', ['4000'])[0])
                
                if not query:
                    self._send_json({"error": "缺少查询参数 q"}, 400)
                    return
                
                context = rag.get_context(query, top_k, max_tokens)
                self._send_json({"query": query, "context": context})
            
            else:
                self._send_json({"error": "未知的路径"}, 404)
        
        def do_POST(self):
            if self.path == '/index':
                content_length = int(self.headers['Content-Length'])
                post_data = self.rfile.read(content_length)
                data = json.loads(post_data.decode('utf-8'))
                
                if 'file' in data:
                    chunks = rag.index_file(data['file'], data.get('metadata'))
                    self._send_json({"indexed": chunks})
                elif 'directory' in data:
                    stats = rag.index_directory(
                        data['directory'],
                        data.get('extensions', ['.md', '.txt', '.json']),
                        data.get('exclude_dirs', ['node_modules', '.git', '__pycache__', 'chromadb'])
                    )
                    self._send_json(stats)
                else:
                    self._send_json({"error": "缺少 file 或 directory 参数"}, 400)
            
            elif self.path == '/clear':
                rag.clear()
                self._send_json({"status": "cleared"})
            
            else:
                self._send_json({"error": "未知的路径"}, 404)
        
        def log_message(self, format, *args):
            print(f"[RAG] {args[0]}")
    
    server = HTTPServer(('127.0.0.1', port), RAGHandler)
    print(f"RAG HTTP服务已启动: http://127.0.0.1:{port}")
    print(f"API端点:")
    print(f"  GET  /health - 健康检查")
    print(f"  GET  /stats - 统计信息")
    print(f"  GET  /search?q=查询&k=5 - 搜索文档")
    print(f"  GET  /context?q=查询&k=5&max_tokens=4000 - 获取上下文")
    print(f"  POST /index - 索引文件或目录")
    print(f"  POST /clear - 清空向量库")
    
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n服务已停止")
        server.shutdown()


if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description="OpenClaw RAG服务")
    parser.add_argument("--port", type=int, default=18790, help="HTTP服务端口")
    parser.add_argument("--persist", default="./chromadb", help="向量库持久化目录")
    parser.add_argument("--model", default="paraphrase-multilingual-MiniLM-L12-v2", help="嵌入模型")
    parser.add_argument("--index", help="索引指定目录")
    parser.add_argument("--search", help="搜索查询")
    
    args = parser.parse_args()
    
    # 初始化RAG
    rag = OpenClawRAG(
        persist_directory=args.persist,
        embedding_model=args.model
    )
    
    # 索引模式
    if args.index:
        rag.index_directory(args.index)
    
    # 搜索模式
    elif args.search:
        results = rag.search(args.search)
        print(f"\n搜索结果: '{args.search}'\n")
        for i, r in enumerate(results):
            print(f"[{i+1}] 相关度: {r['relevance']:.2f}")
            print(f"    来源: {r['metadata'].get('file_name', '未知')}")
            print(f"    内容: {r['document'][:200]}...\n")
    
    # 服务模式
    else:
        create_http_server(rag, args.port)
