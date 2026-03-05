# OpenClaw RAG 服务配置

# 向量数据库配置
CHROMADB_PATH = "./chromadb"

# 嵌入模型配置（多语言支持中文）
EMBEDDING_MODEL = "paraphrase-multilingual-MiniLM-L12-v2"

# 分块配置
CHUNK_SIZE = 1000
CHUNK_OVERLAP = 200

# 检索配置
DEFAULT_TOP_K = 5
MAX_CONTEXT_TOKENS = 4000

# HTTP服务配置
HTTP_PORT = 18790

# 索引配置
INDEX_EXTENSIONS = [".md", ".txt", ".json", ".py", ".js", ".ts"]
EXCLUDE_DIRS = ["node_modules", ".git", "__pycache__", "chromadb", ".openclaw"]

# 工作目录
WORKSPACE = "D:\\AI编程\\openclaw"
