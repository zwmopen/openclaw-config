"""
OpenClaw RAG 集成脚本
将RAG服务与OpenClaw网关集成
"""

import json
import http.client
from typing import Dict, List, Optional


class OpenClawRAGIntegration:
    """OpenClaw RAG集成类"""
    
    def __init__(
        self,
        rag_host: str = "127.0.0.1",
        rag_port: int = 18790
    ):
        """
        初始化集成
        
        Args:
            rag_host: RAG服务主机
            rag_port: RAG服务端口
        """
        self.rag_host = rag_host
        self.rag_port = rag_port
    
    def _rag_request(self, method: str, path: str, data: Optional[Dict] = None) -> Dict:
        """发送RAG服务请求"""
        conn = http.client.HTTPConnection(self.rag_host, self.rag_port)
        
        headers = {"Content-Type": "application/json"}
        body = json.dumps(data) if data else None
        
        conn.request(method, path, body, headers)
        response = conn.getresponse()
        result = json.loads(response.read().decode('utf-8'))
        conn.close()
        
        return result
    
    def search_documents(self, query: str, top_k: int = 5) -> List[Dict]:
        """搜索相关文档"""
        result = self._rag_request("GET", f"/search?q={query}&k={top_k}")
        return result.get("results", [])
    
    def get_context_for_query(self, query: str, top_k: int = 5, max_tokens: int = 4000) -> str:
        """获取查询的上下文"""
        result = self._rag_request("GET", f"/context?q={query}&k={top_k}&max_tokens={max_tokens}")
        return result.get("context", "")
    
    def enhance_prompt(self, user_query: str, system_prompt: str = "") -> str:
        """
        增强用户提示词（添加相关上下文）
        
        Args:
            user_query: 用户查询
            system_prompt: 系统提示词
            
        Returns:
            增强后的提示词
        """
        # 获取相关上下文
        context = self.get_context_for_query(user_query)
        
        # 构建增强提示词
        enhanced_prompt = f"""
{system_prompt}

{context}

用户问题: {user_query}

请基于以上文档内容和你的知识回答用户问题。
"""
        return enhanced_prompt.strip()
    
    def get_stats(self) -> Dict:
        """获取RAG统计信息"""
        return self._rag_request("GET", "/stats")
    
    def is_healthy(self) -> bool:
        """检查RAG服务是否健康"""
        try:
            result = self._rag_request("GET", "/health")
            return result.get("status") == "ok"
        except:
            return False


# 命令行接口
if __name__ == "__main__":
    import sys
    
    integration = OpenClawRAGIntegration()
    
    if len(sys.argv) > 1:
        command = sys.argv[1]
        
        if command == "search":
            query = " ".join(sys.argv[2:])
            print(f"搜索: {query}\n")
            results = integration.search_documents(query)
            for i, r in enumerate(results):
                print(f"[{i+1}] 相关度: {r['relevance']:.2f}")
                print(f"    来源: {r['metadata'].get('file_name', '未知')}")
                print(f"    内容: {r['document'][:200]}...\n")
        
        elif command == "context":
            query = " ".join(sys.argv[2:])
            print(f"上下文: {query}\n")
            context = integration.get_context_for_query(query)
            print(context)
        
        elif command == "enhance":
            query = " ".join(sys.argv[2:])
            print(f"增强提示词: {query}\n")
            enhanced = integration.enhance_prompt(query)
            print(enhanced)
        
        elif command == "stats":
            stats = integration.get_stats()
            print(json.dumps(stats, indent=2, ensure_ascii=False))
        
        elif command == "health":
            if integration.is_healthy():
                print("RAG服务健康")
            else:
                print("RAG服务不可用")
        
        else:
            print(f"未知命令: {command}")
            print("可用命令: search, context, enhance, stats, health")
    else:
        print("OpenClaw RAG集成工具")
        print()
        print("用法:")
        print("  python rag_integration.py search <查询>")
        print("  python rag_integration.py context <查询>")
        print("  python rag_integration.py enhance <查询>")
        print("  python rag_integration.py stats")
        print("  python rag_integration.py health")
