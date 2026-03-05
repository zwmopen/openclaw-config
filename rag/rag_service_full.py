"""
OpenClaw RAG 服务 - 完整版
支持多种嵌入方式：
1. sentence-transformers本地模型（免费）
2. 智谱嵌入API（付费）
3. 硅基流动嵌入API（付费）
"""

import os
import json
import hashlib
import http.client
from pathlib import Path
from typing import List, Dict, Optional
from datetime import datetime
import pickle

# 导入ChromaDB
import chromadb
from chromadb.config import Settings

# 嵌入模型基类
class BaseEmbedding:
    """嵌入模型基类"""
    
    def encode(self, texts: List[str]) -> List[List[float]]:
        raise NotImplementedError
    
    def get_dimension(self) -> int:
        raise NotImplementedError


# Sentence Transformers 本地模型
class SentenceTransformerEmbedding(BaseEmbedding):
    """使用sentence-transformers的本地嵌入模型"""
    
    def __init__(self, model_name: str = "paraphrase-multilingual-MiniLM-L12-v2"):
        """
        初始化
        
        Args:
            model_name: 模型名称，推荐：
                - paraphrase-multilingual-MiniLM-L12-v2 (多语言，384维)
                - sentence-transformers/clip-ViT-B-32-multilingual-v1 (多语言，512维)
                - shibing624/text2vec-base-chinese (中文专用，768维)
        """
        try:
            from sentence_transformers import SentenceTransformer
            print(f"正在加载嵌入模型: {model_name}")
            self.model = SentenceTransformer(model_name)
            self.dimension = self.model.get_sentence_embedding_dimension()
            print(f"模型加载完成，向量维度: {self.dimension}")
        except ImportError:
            raise ImportError("请安装sentence-transformers: pip install sentence-transformers")
    
    def encode(self, texts: List[str]) -> List[List[float]]:
        return self.model.encode(texts).tolist()
    
    def get_dimension(self) -> int:
        return self.dimension


# 智谱嵌入API
class ZhipuEmbedding(BaseEmbedding):
    """智谱AI嵌入模型"""
    
    def __init__(self, api_key: str, model: str = "embedding-2"):
        """
        初始化
        
        Args:
            api_key: 智谱API密钥
            model: 模型名称 (embedding-2, embedding-3)
        """
        self.api_key = api_key
        self.model = model
        self.dimension = 1024  # embedding-2的维度
    
    def encode(self, texts: List[str]) -> List[List[float]]:
        conn = http.client.HTTPSConnection("open.bigmodel.cn")
        
        data = json.dumps({
            "model": self.model,
            "input": texts
        })
        
        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {self.api_key}"
        }
        
        conn.request("POST", "/api/paas/v4/embeddings", data, headers)
        response = conn.getresponse()
        result = json.loads(response.read().decode('utf-8'))
        conn.close()
        
        if "error" in result:
            raise Exception(f"智谱API错误: {result['error']}")
        
        return [item["embedding"] for item in result["data"]]
    
    def get_dimension(self) -> int:
        return self.dimension


# 硅基流动嵌入API
class SiliconFlowEmbedding(BaseEmbedding):
    """硅基流动嵌入模型"""
    
    def __init__(self, api_key: str, model: str = "BAAI/bge-large-zh-v1.5"):
        """
        初始化
        
        Args:
            api_key: 硅基流动API密钥
            model: 模型名称
                - BAAI/bge-large-zh-v1.5 (中文，1024维)
                - BAAI/bge-m3 (多语言，1024维)
        """
        self.api_key = api_key
        self.model = model
        self.dimension = 1024
    
    def encode(self, texts: List[str]) -> List[List[float]]:
        conn = http.client.HTTPSConnection("api.siliconflow.cn")
        
        data = json.dumps({
            "model": self.model,
            "input": texts,
            "encoding_format": "float"
        })
        
        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {self.api_key}"
        }
        
        conn.request("POST", "/v1/embeddings", data, headers)
        response = conn.getresponse()
        result = json.loads(response.read().decode('utf-8'))
        conn.close()
        
        if "error" in result:
            raise Exception(f"硅基流动API错误: {result['error']}")
        
        return [item["embedding"] for item in result["data"]]
    
    def get_dimension(self) -> int:
        return self.dimension


# OpenClaw RAG服务
class OpenClawRAG:
    """OpenClaw RAG服务类"""
    
    EMBEDDING_TYPES = {
        "local": SentenceTransformerEmbedding,
        "zhipu": ZhipuEmbedding,
        "siliconflow": SiliconFlowEmbedding
    }
    
    def __init__(
        self,
        persist_directory: str = "./chromadb",
        embedding_type: str = "local",
        embedding_model: str = "paraphrase-multilingual-MiniLM-L12-v2",
        api_key: str = None,
        chunk_size: int = 1000,
        chunk_overlap: int = 200
    ):
        """
        初始化RAG服务
        
        Args:
            persist_directory: ChromaDB持久化目录
            embedding_type: 嵌入类型 ("local", "zhipu", "siliconflow")
            embedding_model: 模型名称
            api_key: API密钥（智谱或硅基流动）
            chunk_size: 文本分块大小
            chunk_overlap: 分块重叠大小
        """
        self.persist_directory = persist_directory
        self.chunk_size = chunk_size
        self.chunk_overlap = chunk_overlap
        self.embedding_type = embedding_type
        
        # 初始化嵌入模型
        if embedding_type == "local":
            self.embedding = SentenceTransformerEmbedding(embedding_model)
        elif embedding_type == "zhipu":
            self.embedding = ZhipuEmbedding(api_key, embedding_model)
        elif embedding_type == "siliconflow":
            self.embedding = SiliconFlowEmbedding(api_key, embedding_model)
        else:
            raise ValueError(f"不支持的嵌入类型: {embedding_type}")
        
        # 初始化ChromaDB
        print(f"正在初始化ChromaDB: {persist_directory}")
        self.client = chromadb.PersistentClient(path=persist_directory)
        self.collection = self.client.get_or_create_collection(
            name="openclaw_documents",
            metadata={"description": "OpenClaw文档向量库", "embedding_type": embedding_type}
        )
        
        print(f"RAG服务初始化完成，当前文档数: {self.collection.count()}")
    
    def _chunk_text(self, text: str) -> List[str]:
        """将文本分割成块"""
        if len(text) <= self.chunk_size:
            return [text]
        
        chunks = []
        start = 0
        while start < len(text):
            end = start + self.chunk_size
            # 尝试在句子边界分割
            if end < len(text):
                # 向后找句子结束符
                for sep in ['\n\n', '\n', '。', '！', '？', '.', '!', '?']:
                    pos = text.find(sep, end - 100, end + 100)
                    if pos != -1:
                        end = pos + 1
                        break
            chunk = text[start:end].strip()
            if chunk:
                chunks.append(chunk)
            start = end - self.chunk_overlap
        
        return chunks
    
    def _get_file_hash(self, file_path: str) -> str:
        """计算文件哈希值"""
        with open(file_path, 'rb') as f:
            return hashlib.md5(f.read()).hexdigest()
    
    def index_file(self, file_path: str, metadata: Optional[Dict] = None) -> int:
        """索引单个文件"""
        if not os.path.exists(file_path):
            return 0
        
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
        except Exception as e:
            print(f"读取失败 {file_path}: {e}")
            return 0
        
        if not content.strip():
            return 0
        
        chunks = self._chunk_text(content)
        
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
        embeddings = self.embedding.encode(chunks)
        
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
        
        print(f"已索引: {os.path.basename(file_path)} ({len(chunks)} 块)")
        return len(chunks)
    
    def index_directory(
        self,
        directory: str,
        extensions: List[str] = [".md", ".txt", ".json", ".py", ".js", ".ts"],
        exclude_dirs: List[str] = ["node_modules", ".git", "__pycache__", "chromadb", ".openclaw"]
    ) -> Dict:
        """索引整个目录"""
        stats = {
            "total_files": 0,
            "indexed_files": 0,
            "total_chunks": 0,
            "errors": []
        }
        
        for root, dirs, files in os.walk(directory):
            dirs[:] = [d for d in dirs if d not in exclude_dirs]
            
            for file in files:
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
        
        return stats
    
    def search(self, query: str, top_k: int = 5, filter_metadata: Optional[Dict] = None) -> List[Dict]:
        """搜索相关文档"""
        query_embedding = self.embedding.encode([query])[0]
        
        where = None
        if filter_metadata:
            where = filter_metadata
        
        results = self.collection.query(
            query_embeddings=[query_embedding],
            n_results=top_k,
            where=where,
            include=["documents", "metadatas", "distances"]
        )
        
        formatted_results = []
        for i in range(len(results["ids"][0])):
            formatted_results.append({
                "id": results["ids"][0][i],
                "document": results["documents"][0][i],
                "metadata": results["metadatas"][0][i],
                "distance": results["distances"][0][i],
                "relevance": 1 - results["distances"][0][i]
            })
        
        return formatted_results
    
    def get_context(self, query: str, top_k: int = 5, max_tokens: int = 4000) -> str:
        """获取查询上下文"""
        results = self.search(query, top_k)
        
        context_parts = []
        current_length = 0
        
        for i, result in enumerate(results):
            doc = result["document"]
            source = result["metadata"].get("file_name", "未知来源")
            relevance = result["relevance"]
            
            part = f"\n[文档 {i+1}] (相关度: {relevance:.2f}, 来源: {source})\n{doc}\n"
            
            if current_length + len(part) > max_tokens * 4:
                break
            
            context_parts.append(part)
            current_length += len(part)
        
        return f"以下是相关的文档内容:\n{''.join(context_parts)}"
    
    def get_stats(self) -> Dict:
        """获取统计信息"""
        return {
            "total_documents": self.collection.count(),
            "persist_directory": self.persist_directory,
            "embedding_type": self.embedding_type,
            "embedding_dimension": self.embedding.get_dimension()
        }


# HTTP服务
def create_http_server(rag: OpenClawRAG, port: int = 18790):
    """创建HTTP API服务"""
    from http.server import HTTPServer, BaseHTTPRequestHandler
    import urllib.parse
    
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
                if query:
                    results = rag.search(query, top_k)
                    self._send_json({"query": query, "results": results})
                else:
                    self._send_json({"error": "缺少查询参数 q"}, 400)
            elif parsed.path == '/context':
                params = urllib.parse.parse_qs(parsed.query)
                query = params.get('q', [''])[0]
                if query:
                    context = rag.get_context(query)
                    self._send_json({"query": query, "context": context})
                else:
                    self._send_json({"error": "缺少查询参数 q"}, 400)
            else:
                self._send_json({"error": "未知的路径"}, 404)
        
        def do_POST(self):
            if self.path == '/index':
                content_length = int(self.headers['Content-Length'])
                post_data = self.rfile.read(content_length)
                data = json.loads(post_data.decode('utf-8'))
                
                if 'directory' in data:
                    stats = rag.index_directory(data['directory'])
                    self._send_json(stats)
                else:
                    self._send_json({"error": "缺少 directory 参数"}, 400)
            else:
                self._send_json({"error": "未知的路径"}, 404)
        
        def log_message(self, format, *args):
            print(f"[RAG] {args[0]}")
    
    server = HTTPServer(('127.0.0.1', port), RAGHandler)
    print(f"RAG HTTP服务已启动: http://127.0.0.1:{port}")
    print(f"API端点:")
    print(f"  GET  /health - 健康检查")
    print(f"  GET  /stats - 统计信息")
    print(f"  GET  /search?q=查询 - 搜索文档")
    print(f"  GET  /context?q=查询 - 获取上下文")
    print(f"  POST /index - 索引目录")
    
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
    parser.add_argument("--embedding-type", default="local", choices=["local", "zhipu", "siliconflow"], help="嵌入类型")
    parser.add_argument("--embedding-model", default="paraphrase-multilingual-MiniLM-L12-v2", help="嵌入模型")
    parser.add_argument("--api-key", help="API密钥（智谱或硅基流动）")
    parser.add_argument("--index", help="索引指定目录")
    parser.add_argument("--search", help="搜索查询")
    
    args = parser.parse_args()
    
    rag = OpenClawRAG(
        persist_directory=args.persist,
        embedding_type=args.embedding_type,
        embedding_model=args.embedding_model,
        api_key=args.api_key
    )
    
    if args.index:
        rag.index_directory(args.index)
    elif args.search:
        results = rag.search(args.search)
        print(f"\n搜索结果: '{args.search}'\n")
        for i, r in enumerate(results):
            print(f"[{i+1}] 相关度: {r['relevance']:.2f}")
            print(f"    来源: {r['metadata'].get('file_name', '未知')}")
            print(f"    内容: {r['document'][:200]}...\n")
    else:
        create_http_server(rag, args.port)
