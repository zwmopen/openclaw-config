# OpenClaw Token优化配置指南

## 问题解答

### 1. 会话记忆存储位置

会话记忆默认存储在用户目录：
- **Windows:** `C:\Users\用户名\.openclaw\workspace\memory\`
- **工作目录:** 您设置的workspace目录下的 `memory/` 子目录

**可以修改到其他位置吗？**
可以！通过设置 `agents.defaults.workspace` 来改变工作目录。

### 2. 记忆文件会占用很多空间吗？

不会！记忆文件是纯文本Markdown，非常小：
- 每日记忆文件通常只有几KB
- 长期记忆文件由您手动维护，大小可控

---

## Token优化配置

### 方案一：启用上下文压缩（推荐）

```bash
# 启用压缩模式
openclaw config set -- agents.defaults.compaction.mode "safeguard"

# 设置保留的token数量
openclaw config set -- agents.defaults.compaction.reserveTokens 16384

# 设置保留最近的token数量
openclaw config set -- agents.defaults.compaction.keepRecentTokens 20000
```

### 方案二：启用缓存TTL修剪

```bash
# 启用缓存TTL修剪
openclaw config set -- agents.defaults.contextPruning.mode "cache-ttl"

# 设置TTL为1小时
openclaw config set -- agents.defaults.contextPruning.ttl "1h"

# 保留最近的助手消息数量
openclaw config set -- agents.defaults.contextPruning.keepLastAssistants 3

# 软修剪比例（保留30%）
openclaw config set -- agents.defaults.contextPruning.softTrimRatio 0.3

# 硬清除比例（超过50%时清除）
openclaw config set -- agents.defaults.contextPruning.hardClearRatio 0.5
```

### 方案三：心跳保持缓存温暖

```bash
# 设置心跳间隔为55分钟（小于缓存TTL）
openclaw config set -- agents.defaults.heartbeat.every "55m"
```

---

## 完整优化配置

```json
{
  "agents": {
    "defaults": {
      "contextPruning": {
        "mode": "cache-ttl",
        "ttl": "1h",
        "keepLastAssistants": 3,
        "softTrimRatio": 0.3,
        "hardClearRatio": 0.5,
        "minPrunableToolChars": 50000,
        "softTrim": {
          "maxChars": 4000,
          "headChars": 1500,
          "tailChars": 1500
        },
        "hardClear": {
          "enabled": true,
          "placeholder": "[旧工具结果已清除]"
        }
      },
      "compaction": {
        "mode": "safeguard",
        "reserveTokens": 16384,
        "keepRecentTokens": 20000
      },
      "heartbeat": {
        "every": "55m"
      }
    }
  }
}
```

---

## Token节省原理

### 1. 上下文修剪 (Context Pruning)
- 自动删除旧的工具调用结果
- 保留最近的对话上下文
- 不影响会话历史文件

### 2. 压缩 (Compaction)
- 当上下文超过阈值时自动压缩
- 保留关键信息
- 减少发送给LLM的token数量

### 3. 缓存TTL (Cache TTL)
- 利用模型提供商的缓存机制
- 避免重复发送相同内容
- 心跳保持缓存有效

---

## 成本对比

| 配置 | 缓存写入 | 缓存读取 | 输入Token |
|------|---------|---------|----------|
| 无优化 | 高 | 低 | 高 |
| 修剪+压缩 | 低 | 高 | 低 |
| 节省比例 | ~50% | ~30% | ~40% |

---

## 推荐配置（平衡性能和成本）

```bash
# 一键配置
openclaw config set -- agents.defaults.contextPruning.mode "cache-ttl"
openclaw config set -- agents.defaults.contextPruning.ttl "1h"
openclaw config set -- agents.defaults.compaction.mode "safeguard"
openclaw config set -- agents.defaults.heartbeat.every "55m"
```

---

## 注意事项

1. **修剪不会删除历史文件** - 只是减少发送给LLM的内容
2. **压缩是智能的** - 会保留关键决策和上下文
3. **心跳消耗很少** - 只发送轻量级ping请求
4. **TTL根据模型调整** - 不同模型缓存TTL不同

---

## 记忆文件管理

### 清理旧记忆
```bash
# 删除30天前的记忆文件
Get-ChildItem "C:\Users\z\.openclaw\workspace\memory" -Recurse | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } | Remove-Item
```

### 手动维护长期记忆
编辑 `MEMORY.md` 文件，只保留重要信息。
