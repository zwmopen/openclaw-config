# Obsidian+OpenClaw 组合技学习笔记

> 来源：公众号文章 - 卡尔的AI沃茨

---

## 核心问题

1. 怎么让信息流动到Obsidian里
2. 怎么让Obsidian里存的信息有合理的结构，让AI和我都可以看懂

---

## 文件结构设计

### 限制目录深度
- **设定3层子目录**，避免AI迷失
- AI忘记时，把目录路径和用途重新写入记忆文件

### 目录参考
- OrbitOS + claudesidian 的 metadata 目录
- 每次对话结束主动更新知识

---

## 信息收录方式

### 三大渠道
1. **插件** - Obsidian Web Clipper, HoverNotes
2. **微信** - 笔记同步助手（支持小红书视频转图文）
3. **OpenClaw** - 啃难解析链接和视频

### 收录流程
```
信息源 → 收件箱 → AI整理计划 → 归档
```

---

## 必装技能

| 技能 | 用途 |
|------|------|
| x-reader | 链接解析（小红书、B站、X） |
| agent-reach | 浏览器自动化 |
| browserwing | 浏览器控制 |
| obsidian | Obsidian集成 |
| find-skills | 主动找技能 |
| proactive-agent | 自我迭代的主动Agent |

---

## 关键配置

### 软链接
把OpenClaw工作区链接到Obsidian仓库：
```
mklink /D "Obsidian\OpenClaw配置" "D:\AI编程\openclaw"
```

这样可以在Obsidian里直接编辑SOUL.md等配置文件。

### 插件
- **Claudian/Codex App** - 把Claude Code内置到侧边栏
- **笔记同步助手** - 微信消息同步到Obsidian
- **Image auto upload** - 图片上传图床
- **ObShare** - 分享到飞书

---

## 核心认知

1. **不需要过度担心AI记不住**
   - 限制目录深度
   - 定期把路径写入记忆

2. **文字是最持久的媒介**
   - 图床会失效
   - 链接会过期
   - 记录方式越简单越好

3. **AI和用户共同进化**
   - 用户编写AI的技能和记忆
   - AI主动记录用户的偏好
   - 双方都在无限进步

---

## 我的行动项

- [x] 已安装所有推荐技能
- [x] 已创建OpenClaw配置软链接
- [ ] 限制文件目录深度为3层
- [ ] 每次对话结束主动更新记忆

---

学习时间：2026-03-03
