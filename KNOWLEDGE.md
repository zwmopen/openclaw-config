# KNOWLEDGE.md - 我学到的知识

## 知识库结构

### Obsidian 目录结构（2026-03-02 创建）

```
D:\Program Files\Obsidian\zwm\zwm\
├── 00-收件箱/          # 新信息入口
│   ├── 待处理/         # 待整理的内容
│   └── 素材/           # x-reader 输出
├── 01-知识库/          # 沉淀的知识
│   ├── 摄影/           # 摄影相关
│   ├── 美妆/           # 美妆相关
│   ├── 对标账号/       # 对标账号信息
│   ├── 选题库/         # 选题素材
│   └── 运营方法/       # 运营方法论
├── 02-项目/            # 项目文档
├── 03-日常/            # 日常记录
├── 04-存档/            # 归档内容
└── OpenClaw配置/       # 软链接 → D:\AI编程\openclaw
```

---

## 已安装的工具

### ✅ 技能状态

| 技能 | 版本 | 功能 |
|------|------|------|
| x-reader | 0.2.0 | URL解析（小红书、B站、公众号等）|
| agent-reach | 1.2.0 | 12+平台爬虫 |
| browserwing | v1.0.0 | 浏览器自动化 |
| xreach-cli | 0.3.0 | Twitter/X 爬取 |
| gh CLI | v2.42.1 | GitHub 命令行（需认证）|
| Node.js | v22.14.0 | JavaScript 运行时 |
| mcporter | 0.7.3 | MCP 工具（需配置）|
| RAG | 1.0 | 向量数据库检索（硅基流动嵌入）|
| find-skills | ✅ | 发现和安装技能 |
| proactive-agent | 3.0.0 | 自我进化、主动行为、记忆持久化 |
| obsidian | ✅ | 写入 Obsidian vault |
| memU | ✅ | 24/7 主动代理记忆系统 |
| free-search | ✅ | 免费网络搜索（DuckDuckGo）|

### ✅ 已安装技能（19个）- 2026-03-05 更新

**来源**: 卡尔的AI沃茨 - 高级OpenClaw第一步

| 技能 | 版本 | 用途 | 状态 |
|------|------|------|------|
| self-improving | 1.2.3 | 记忆升级神器 | ✅ |
| openclaw-tavily-search | 0.1.0 | 高质量联网搜索 | ⚠️ 需配置API |
| transcript | 1.4.1 | 视频字幕提取 | ✅ |
| schedule | 1.0.2 | 日程管理 | ✅ |
| notion | 1.0.0 | Notion集成 | ⚠️ 需配置API |
| cross-platform-poster | 1.0.0 | 多平台同步发布 | ✅ |
| anygen-skill | 1.0.0 | AI生成技能 | ✅ |
| anygen-deep-research | 1.0.0 | 深度研究 | ✅ |
| anygen-slide-generator | 1.0.0 | PPT生成 | ✅ |
| anygen-data-analysis | 1.0.0 | 数据分析 | ✅ |
| fal-ai | 0.1.0 | 图像生成 | ✅ |
| ffmpeg-video-editor | 1.0.0 | 视频编辑 | ✅ |
| agent-memory | 1.0.0 | 代理记忆 | ✅ |
| automation-workflows | 0.1.0 | 自动化工作流 | ✅ |
| qmd | 1.0.0 | Markdown增强 | ✅ |
| skill-vetter | 1.0.0 | 技能审查 | ✅ |
| multi-search-engine | 1.0.0 | 多引擎搜索 | ✅ |
| save-to-obsidian | 1.1.0 | Obsidian保存 | ✅ |
| find-skills | 0.1.0 | 技能搜索 | ✅ |

**安装进度**: 20/20 已安装 (100%)

### ✅ 新增技能（2026-03-05）

| 技能 | 版本 | 用途 | 状态 |
|------|------|------|------|
| notebooklm-py | 0.3.3 | Google NotebookLM API 集成 | ⚠️ 需 Google OAuth |

### ⏳ 待配置API

| 技能 | 配置方法 |
|------|----------|
| Tavily Search | 需要 Tavily API Key (https://tavily.com) |
| Notion | 需要 Notion Integration Token |

### ✅ 渠道状态（6/12 可用）

| 平台 | 状态 | 备注 |
|------|------|------|
| YouTube | ✅ | 视频信息+字幕 |
| Twitter/X | ✅ | 推文读取+搜索 |
| RSS | ✅ | 订阅源读取 |
| B站 | ✅ | 视频信息+字幕 |
| 任意网页 | ✅ | Jina Reader |
| GitHub | ⚠️ | gh CLI已装，需 `gh auth login` |
| 小红书 | ⬜ | 需要 Docker |
| 抖音 | ⬜ | 需要 mcporter 配置 |
| Reddit | ⬜ | 需要代理 |

### 配置文件位置

- x-reader 配置: `D:\AI编程\openclaw\skills\x-reader\.env`
- OpenClaw 配置: `D:\AI编程\openclaw\.openclaw\openclaw.json`
- 密钥存储: `D:\AI编程\openclaw\SECRETS.md`

### API 密钥状态

| API | 状态 | 用途 |
|-----|------|------|
| Groq API | ✅ 已配置 | 视频转文字 |
| 联通元景 GLM-5 | ✅ 已配置 | 主力模型 |
| 联通云 GLM-5 | ✅ 已配置 | OpenClaw专用 |
| 联通云 GLM-5 免费版 | ✅ 已配置 | 0元/月 |
| 硅基流动 DeepSeek | ✅ 已配置 | 备用模型 |
| 飞书 Bot | ✅ 已配置 | 消息通道 |
| GitHub | ✅ 已配置 | 代码仓库 |

---

## 待配置项（可选）

### 1. GitHub CLI 认证
```bash
gh auth login
```
选择 GitHub.com → HTTPS → Yes

### 2. Exa API（语义搜索）
- 地址：https://exa.ai
- 免费额度：1000次/月
- 配置：`mcporter config add exa https://mcp.exa.ai/mcp`

### 3. 小红书/抖音（需要 Docker）
```bash
# 小红书
docker run -d --name xiaohongshu-mcp -p 18060:18060 xpzouying/xiaohongshu-mcp
mcporter config add xiaohongshu http://localhost:18060/mcp

# 抖音
pip install douyin-mcp-server
douyin-mcp-server
mcporter config add douyin http://localhost:18070/mcp
```

---

## 工作流

### 信息收集流程

```
1. 发送链接给 OpenClaw
2. x-reader 解析内容
3. 输出到 Obsidian/00-收件箱/素材/
4. 整理后移入 01-知识库/ 对应目录
```

### 知识沉淀触发器

- 学到新知识 → 更新 KNOWLEDGE.md
- 发现新工作流 → 添加到工作流
- 新 API 配置 → 记录到配置文件位置
