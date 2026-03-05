# OpenClaw 技能目录

> 最后更新：2026-03-04

---

## 📂 技能分类

### 📝 笔记与记忆

| 技能 | 触发方式 | 说明 |
|------|---------|------|
| note-organizer | "梳理笔记"、"整理笔记" | 按格式整理Obsidian笔记 |
| obsidian | "在Obsidian..." | Obsidian笔记操作 |
| memU | "记录"、"记住" | 记忆管理（自动） |

### 🌐 网络与浏览器

| 技能 | 触发方式 | 说明 |
|------|---------|------|
| free-search | "搜索..." | 免费网络搜索（DuckDuckGo，无需API）|
| x-reader | "解析链接"、"读取网页" | 解析网页/公众号文章 |
| browserwing | "浏览器..." | 浏览器自动化控制 |
| agent-reach | "打开网页"、"访问网站" | 浏览器访问 |
| summarize | "总结..."、"摘要..." | 内容摘要提取 |

### 🤖 智能与学习

| 技能 | 触发方式 | 说明 |
|------|---------|------|
| find-skills | "有没有X技能"、"找个技能" | 自动搜索安装技能 |
| proactive-agent | 自动运行 | 自我迭代、学习改进 |
| coding-agent | "写代码"、"编程"、"帮我开发" | 编程任务代理 |
| github | "GitHub..."、"创建PR"、"查看Issue" | GitHub操作 |
| gh-issues | "处理Issue" | 自动处理GitHub Issues |

### ⏰ 任务管理

| 技能 | 触发方式 | 说明 |
|------|---------|------|
| timeboxing | "时间盒子"、"规划时间" | 时间盒子任务规划 |

### 🎤 多媒体

| 技能 | 触发方式 | 说明 |
|------|---------|------|
| openai-whisper | "转文字"、"语音识别" | 本地语音转文字 |

### 📦 系统内置

| 技能 | 触发方式 | 说明 |
|------|---------|------|
| skill-creator | "创建技能" | 创建新技能 |
| healthcheck | "检查系统"、"安全检查" | 系统安全检查 |
| weather | "天气" | 查询天气 |
| canvas | "画布"、"展示" | 画布展示 |
| notion | "Notion..." | Notion笔记操作 |
| trello | "Trello..." | Trello任务管理 |
| openai-image-gen | "生成图片" | AI图片生成（需API）|

---

## 🔧 自定义技能（已创建）

### free-search（免费搜索）
- **位置**: `C:\Users\z\.openclaw\skills\free-search\`
- **触发**: "搜索..."
- **功能**: 使用 DuckDuckGo 免费搜索，无需 API Key
- **创建时间**: 2026-03-04
- **配置过程**:
  1. 创建技能目录结构
  2. 编写 SKILL.md（技能说明）
  3. 编写 skill.json（技能配置）
  4. 编写 scripts/search.js（搜索脚本）
  5. 使用 DuckDuckGo HTML 搜索 + Instant Answer API
  6. 完全免费，无限制

---

## 🎯 快速命令

### 笔记相关
```
"梳理笔记"           → 按格式整理当前笔记
"整理笔记"           → 同上
"记录选题"           → 记录选题到选题文件夹
"记录想法"           → 记录想法到想法文件夹
"记录并深化"         → 记录 + 扩展思考
"记录并变选题"       → 记录 + 分析选题角度
```

### 网络相关
```
"解析链接 <URL>"     → 解析网页内容
"读取网页 <URL>"     → 同上
"打开浏览器"         → 打开浏览器
```

### 任务相关
```
"今天任务"           → 显示今天任务列表
"添加任务 <任务>"    → 添加新任务
"完成任务 <任务>"    → 标记任务完成
"时间盒子"           → 用时间盒子方法规划
```

### 系统相关
```
"状态"               → 显示系统状态
"技能列表"           → 显示所有技能
"创建技能 <名称>"    → 创建新技能
```

---

## 📁 文件位置

### 自定义技能
```
D:\AI编程\openclaw\skills\
├── note-organizer/   # 笔记整理
├── timeboxing/       # 时间盒子
├── obsidian/         # Obsidian操作
├── memU/             # 记忆管理
└── ...
```

### 内置技能
```
C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node_modules\openclaw\skills\
```

---

## 🔧 配置文件

| 文件 | 位置 | 说明 |
|------|------|------|
| 主配置 | `D:\AI编程\openclaw\.openclaw\openclaw.json` | 模型、渠道、技能配置 |
| 记忆文件 | `D:\AI编程\openclaw\MEMORY.md` | 长期记忆 |
| 用户信息 | `D:\AI编程\openclaw\USER.md` | 用户偏好 |
| 灵魂文件 | `D:\AI编程\openclaw\SOUL.md` | AI身份定义 |

---

## 📞 常用操作

### 启动OpenClaw
- 桌面快捷方式：双击 `OpenClaw.lnk`
- 开机自启动：已配置，自动运行

### 网关地址
- 地址：`http://127.0.0.1:18789`
- Token：`2d65353ea3422e1bd863c865f7cc9b3d92514be0fd19ebd8`

### 模型配置
- 主模型：GLM-5 (联通元景，免费)
- 视觉模型：GLM-4V-Flash (智谱，免费)
- Token查询：https://maas.ai-yuanjing.com/aibase/userCenter/realTime

---

## 🚀 待开发技能

| 技能 | 说明 | 状态 |
|------|------|------|
| 记录选题 | 自动分类选题 | 待开发 |
| 记录想法 | 自动记录想法 | 待开发 |
| 记录并深化 | 记录 + 扩展思考 | 待开发 |
| 记录并变选题 | 记录 + 分析选题 | 待开发 |
| 记录并梳理 | 记录 + 结构化 | 待开发 |

---

## 📝 笔记库路径

```
D:\Program Files\Obsidian\zwm\.zwm\
├── 00-收件箱/        # 临时收集
├── 00待办事项/       # 任务管理
├── OpenClaw/         # 技能库（主位置）
├── 选题/             # 选题库
├── 想法/             # 想法库
├── 素材/             # 素材库
└── ...
```

---

## 🔧 技能库位置

**主技能库：** `D:\Program Files\Obsidian\zwm\.zwm\OpenClaw\`

**写技能 → 直接写到这里**
**读技能 → 直接读这里**

这样我不需要搜索，直接定位，节省token。
