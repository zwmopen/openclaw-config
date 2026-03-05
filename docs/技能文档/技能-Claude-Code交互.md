# Claude Code 交互技能

> 让 OpenClaw 能够与 Claude Code CLI 进行实时对话，实现"代理编程"能力

---

## 概述

**Claude Code** 是 Anthropic 官方的命令行工具，可以：
- 自动读取、编辑、创建文件
- 执行命令
- 进行复杂的代码重构和项目开发

**OpenClaw 作为代理**，通过 `exec` + `process` 工具，让用户通过飞书/Telegram 等渠道直接与 Claude Code 对话。

---

## 核心原理

```
用户（飞书/Telegram）
    ↓ 发消息
OpenClaw（我）
    ↓ exec 启动 Claude Code CLI（pty: true）
Claude Code 进程（后台运行）
    ↓ process 工具读写
OpenClaw（我）
    ↓ 返回结果
用户（飞书/Telegram）
```

---

## 使用步骤

### 1. 启动 Claude Code

```
exec 工具：
- command: "claude" 或 "claude --dangerously-skip-permissions"
- pty: true（必须！否则无法交互）
- background: true
- yieldMs: 30000（等待30秒让进程启动）
```

**注意：**
- Windows 上必须用 PowerShell 或 cmd 启动
- `--dangerously-skip-permissions` 可以跳过权限确认，但会提示不安全
- 不加这个参数，Claude Code 每个操作都会问权限

### 2. 发送问题/指令

```
process 工具：
- action: "write"
- sessionId: 上一步返回的会话ID
- data: 用户的问题或指令
- eof: false（保持连接）
```

### 3. 读取回复

```
process 工具：
- action: "poll"
- sessionId: 会话ID
- timeout: 60000（等待60秒）
```

### 4. 权限确认（重要！）

**Claude Code 会经常问：**
```
? Do you want to allow Claude to read [文件路径]? (y/n)
? Do you want to allow Claude to edit [文件路径]? (y/n)
? Do you want to allow Claude to execute [命令]? (y/n)
```

**自动授权方法：**
```
process 工具：
- action: "write"
- sessionId: 会话ID
- data: "y" 或 "yes"
```

### 5. 结束会话

```
process 工具：
- action: "kill"
- sessionId: 会话ID
```

---

## 完整示例

### 启动会话

```javascript
// 1. 启动 Claude Code
exec({
  command: "claude",
  pty: true,
  background: true,
  yieldMs: 30000
})
// 返回 sessionId: "xxx"

// 2. 等待 Claude Code 启动完成
process({
  action: "poll",
  sessionId: "xxx",
  timeout: 30000
})
// 返回 Claude Code 的欢迎信息
```

### 发送问题

```javascript
// 3. 发送问题
process({
  action: "write",
  sessionId: "xxx",
  data: "帮我读取 D:\\project\\README.md 文件\n"
})

// 4. 读取回复
process({
  action: "poll",
  sessionId: "xxx",
  timeout: 60000
})
// 返回：? Do you want to allow Claude to read D:\project\README.md? (y/n)
```

### 自动授权

```javascript
// 5. 自动授权
process({
  action: "write",
  sessionId: "xxx",
  data: "y\n"
})

// 6. 继续读取结果
process({
  action: "poll",
  sessionId: "xxx",
  timeout: 60000
})
// 返回文件内容
```

### 结束会话

```javascript
// 7. 结束
process({
  action: "kill",
  sessionId: "xxx"
})
```

---

## 实际对话流程

**用户说：** "问 Claude Code：帮我看看这个项目的结构"

**OpenClaw 执行：**

1. 检查是否有活跃的 Claude Code 会话
   - 如果没有，启动新会话
   - 如果有，复用

2. 发送用户问题到 Claude Code

3. 等待回复
   - 如果是权限确认，自动回复 "y"
   - 如果是正常回复，返回给用户

4. 继续监听，直到 Claude Code 完成任务

---

## 权限处理策略

### 策略 A：完全自动授权

每次 Claude Code 问权限，自动回复 "y"

**优点：** 快速，用户无需等待
**缺点：** 不安全，可能执行危险操作

**实现：**
```javascript
// 检测权限问题
if (response.includes("? Do you want to allow")) {
  process({ action: "write", data: "y\n" })
}
```

### 策略 B：智能授权

根据操作类型决定：
- 读取文件 → 自动授权
- 编辑文件 → 自动授权（在安全目录内）
- 执行命令 → 询问用户

**优点：** 平衡安全与效率
**缺点：** 需要更多逻辑判断

### 策略 C：用户确认

所有权限问题都转发给用户确认

**优点：** 最安全
**缺点：** 慢，体验差

---

## 注意事项

### 1. Claude Code 启动慢

- 首次启动需要 5-30 秒
- 建议用 `yieldMs: 30000` 等待

### 2. 会话持久化

- 每次启动都是新会话，Claude Code 不记得之前的对话
- 可以在同一个会话中连续对话，直到任务完成

### 3. 换行符

- 发送命令时，末尾要加 `\n`
- Windows 上用 `\r\n` 或直接 `\n` 都可以

### 4. 编码问题

- Windows PowerShell 默认编码可能有问题
- 建议设置 `$OutputEncoding = [System.Text.Encoding]::UTF8`

### 5. 超时处理

- Claude Code 有时会很慢（特别是大项目）
- 设置合理的 timeout（60-120秒）
- 超时后可以继续 poll，不一定需要 kill

---

## 适用场景

### 适合

- 复杂的代码重构
- 大型项目开发
- 需要文件操作的任务
- 代码审查
- 调试问题

### 不适合

- 简单的笔记整理（用 read/edit 更快）
- 快速问答（用 OpenClaw 自己更快）
- 不需要文件操作的任务

---

## API Key 要求

**重要：** Claude Code 需要 Anthropic API Key

- 国内 API（联通元景、智谱、硅基流动）**不兼容**
- 必须用 Anthropic 官方 API：https://console.anthropic.com
- 需要绑定海外信用卡

**替代方案：**
- 用 OpenClaw + 国产模型（功能类似，但没有 Claude Code 的文件操作能力）
- 用 Cursor 等支持 OpenAI 格式的工具

---

## 故障排查

### 1. Claude Code 无法启动

检查：
- Node.js 版本 ≥ 18
- API Key 是否配置正确
- 网络是否能访问 Anthropic API

### 2. 权限问题不断

解决：
- 使用 `--dangerously-skip-permissions` 启动
- 或实现自动授权逻辑

### 3. 回复乱码

解决：
- 设置 UTF-8 编码
- 检查终端编码设置

### 4. 超时无响应

解决：
- 增加 timeout
- 检查网络连接
- 检查 API 配额

---

## 与其他技能的配合

### 配合 note-organizer

- Claude Code 做代码任务
- note-organizer 做笔记整理
- 分工明确，效率更高

### 配合 x-reader

- x-reader 解析网页内容
- Claude Code 处理解析后的文本
- 形成完整的内容处理流程

---

## 更新日志

- **2026-03-04**: 创建文档，总结交互经验
