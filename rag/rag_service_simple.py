"""
OpenClaw RAG 服务 - 简化版
使用OpenAI兼容API进行向量化，避免torch版本冲突
"""

import os
import json
import hashlib
import http.client
from pathlib import Path
from typing import List, Dict, Optional
from datetime import datetime

# 尝试导入ChromaDB
try:
    import chromadb
    from chromadb.config import Settings
    CHROMADB_AVAILABLE = True
except ImportError:
    CHROMADB_AVAILABLE = False
    print("警告: ChromaDB未安装，请运行: python -m pip install chromadb")


class OpenAIEmbedding:
    """使用OpenAI兼容API的嵌入模型"""
    
    def __init__(self, api_key: str, base_url: str, model: str = "text-embedding-3-small"):
        self.api_key = api_key
        self.base_url = base_url.replace("https://", "").replace("http://", "")
        self.model = model
    
    def encode(self, texts: List[str]) -> List[List[float]]:
        """获取文本的嵌入向量"""
        conn = http.client.HTTPSConnection(self.base_url)
        
        data = json.dumps({
            "input": texts,
            "model": self.model
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
            raise Exception(f"Embedding API错误: {result['error']}")
        
        return [item["embedding"] for item in result["data"]]


class SimpleEmbedding:
    """简单的本地嵌入模型（基于TF-IDF）"""
    
    def __init__(self):
        self.vocab = {}
        self.idf = {}
        self.vocab_size = 1000  # 默认词汇表大小
    
    def save(self, path: str):
        """保存模型"""
        import pickle
        with open(path, 'wb') as f:
            pickle.dump({
                'vocab': self.vocab,
                'idf': self.idf,
                'vocab_size': self.vocab_size
            }, f)
    
    def load(self, path: str):
        """加载模型"""
        import pickle
        with open(path, 'rb') as f:
            data = pickle.load(f)
            self.vocab = data['vocab']
            self.idf = data['idf']
            self.vocab_size = data['vocab_size']
    
    def fit(self, texts: List[str]):
        """训练词汇表"""
        doc_count = len(texts)
        word_doc_count = {}
        
        for text in texts:
            words = set(text.lower().split())
            for word in words:
                word_doc_count[word] = word_doc_count.get(word, 0) + 1
        
        self.vocab = {word: idx for idx, word in enumerate(word_doc_count.keys())}
        self.idf = {word: doc_count / count for word, count in word_doc_count.items()}
        self.vocab_size = len(self.vocab) if self.vocab else 1000
        print(f"词汇表大小: {self.vocab_size}")
    
    def encode(self, texts: List[str]) -> List[List[float]]:
        """编码文本为向量"""
        vectors = []
        
        for text in texts:
            words = text.lower().split()
            word_count = {}
            for word in words:
                word_count[word] = word_count.get(word, 0) + 1
            
            # 创建TF-IDF向量
            vector = [0.0] * self.vocab_size
            
            for word, count in word_count.items():
                if word in self.vocab:
                    idx = self.vocab[word]
                    if idx < self.vocab_size:
                        tf = count / len(words) if words else 0
                        idf = self.idf.get(word, 1.0)
                        vector[idx] = tf * idf
            
            # 归一化
            norm = sum(v * v for v in vector) ** 0.5
            if norm > 0:
                vector = [v / norm for v in vector]
            
            vectors.append(vector)
        
        return vectors


class OpenClawRAG:
    """OpenClaw RAG服务类"""
    
    def __init__(
        self,
        persist_directory: str = "./chromadb",
        embedding_type: str = "simple",
        api_key: str = None,
        base_url: str = None,
        chunk_size: int = 1000,
        chunk_overlap: int = 200
    ):
        """
        初始化RAG服务
        
        Args:
            persist_directory: ChromaDB持久化目录
            embedding_type: 嵌入类型 ("simple", "openai")
            api_key: API密钥（OpenAI兼容API）
            base_url: API基础URL
            chunk_size: 文本分块大小
            chunk_overlap: 分块重叠大小
        """
        self.persist_directory = persist_directory
        self.chunk_size = chunk_size
        self.chunk_overlap = chunk_overlap
        
        if not CHROMADB_AVAILABLE:
            raise RuntimeError("请先安装ChromaDB: python -m pip install chromadb")
        
        # 初始化嵌入模型
        if embedding_type == "openai" and api_key and base_url:
            self.embedding = OpenAIEmbedding(api_key, base_url)
        else:
            self.embedding = SimpleEmbedding()
        
        self.embedding_model_path = os.path.join(persist_directory, "embedding_model.pkl")
        
        # 初始化ChromaDB
        print(f"正在初始化ChromaDB: {persist_directory}")
        self.client = chromadb.PersistentClient(path=persist_directory)
        self.collection = self.client.get_or_create_collection(
            name="openclaw_documents",
            metadata={"description": "OpenClaw文档向量库"}
        )
        
        # 加载已有的嵌入模型
        if os.path.exists(self.embedding_model_path):
            print("加载已有的嵌入模型...")
            self.embedding.load(self.embedding_model_path)
        
        print(f"RAG服务初始化完成，当前文档数: {self.collection.count()}")
    
    def _chunk_text(self, text: str) -> List[str]:
        """将文本分割成块"""
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
        """索引单个文件"""
        if not os.path.exists(file_path):
            print(f"文件不存在: {file_path}")
            return 0
        
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
        except Exception as e:
            print(f"读取文件失败 {file_path}: {e}")
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
        
        print(f"已索引文件: {file_path} ({len(chunks)} 个块)")
        return len(chunks)
    
    def index_directory(
        self,
        directory: str,
        extensions: List[str] = [".md", ".txt", ".json"],
        exclude_dirs: List[str] = ["node_modules", ".git", "__pycache__", "chromadb"]
    ) -> Dict:
        """索引整个目录"""
        stats = {
            "total_files": 0,
            "indexed_files": 0,
            "total_chunks": 0,
            "errors": []
        }
        
        # 先收集所有文本用于训练简单嵌入模型
        if isinstance(self.embedding, SimpleEmbedding):
            all_texts = []
            for root, dirs, files in os.walk(directory):
                dirs[:] = [d for d in dirs if d not in exclude_dirs]
                for file in files:
                    ext = os.path.splitext(file)[1].lower()
                    if ext in extensions:
                        file_path = os.path.join(root, file)
                        try:
                            with open(file_path, 'r', encoding='utf-8') as f:
                                all_texts.append(f.read())
                        except:
                            pass
            
            if all_texts:
                print(f"训练嵌入模型（{len(all_texts)} 个文档）...")
                self.embedding.fit(all_texts)
                # 保存训练好的模型
                os.makedirs(os.path.dirname(self.embedding_model_path), exist_ok=True)
                self.embedding.save(self.embedding_model_path)
                print(f"嵌入模型已保存到: {self.embedding_model_path}")
        
        # 索引文件
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
    
    def search(self, query: str, top_k: int = 5) -> List[Dict]:
        """搜索相关文档"""
        query_embedding = self.embedding.encode([query])[0]
        
        results = self.collection.query(
            query_embeddings=[query_embedding],
            n_results=top_k,
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
            "persist_directory": self.persist_directory
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
    parser.add_argument("--index", help="索引指定目录")
    parser.add_argument("--search", help="搜索查询")
    
    args = parser.parse_args()
    
    rag = OpenClawRAG(persist_directory=args.persist)
    
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
