---
name: slack
description: "通过slack工具从OpenClaw控制Slack，包括对消息反应或在Slack频道或DM中置顶/取消置顶项目。"
---

# Slack技能

使用 `slack` 进行反应、管理置顶、发送/编辑/删除消息以及获取成员信息。

## 输入收集

- `channelId` 和 `messageId`（Slack消息时间戳，如 `1712023032.1234`）
- 反应需要 `emoji`（Unicode或 `:名称:`）
- 发送消息需要 `to` 目标（`channel:<id>` 或 `user:<id>`）和 `content`

## 操作

### 反应消息

```json
{
  "action": "react",
  "channelId": "C123",
  "messageId": "1712023032.1234",
  "emoji": "✅"
}
```

### 列出反应

```json
{
  "action": "reactions",
  "channelId": "C123",
  "messageId": "1712023032.1234"
}
```

### 发送消息

```json
{
  "action": "sendMessage",
  "to": "channel:C123",
  "content": "来自OpenClaw的问候"
}
```

### 编辑消息

```json
{
  "action": "editMessage",
  "channelId": "C123",
  "messageId": "1712023032.1234",
  "content": "更新后的文本"
}
```

### 删除消息

```json
{
  "action": "deleteMessage",
  "channelId": "C123",
  "messageId": "1712023032.1234"
}
```

### 读取最近消息

```json
{
  "action": "readMessages",
  "channelId": "C123",
  "limit": 20
}
```

### 置顶消息

```json
{
  "action": "pinMessage",
  "channelId": "C123",
  "messageId": "1712023032.1234"
}
```

### 取消置顶

```json
{
  "action": "unpinMessage",
  "channelId": "C123",
  "messageId": "1712023032.1234"
}
```

### 列出置顶项目

```json
{
  "action": "listPins",
  "channelId": "C123"
}
```

### 成员信息

```json
{
  "action": "memberInfo",
  "userId": "U123"
}
```

### 表情列表

```json
{
  "action": "emojiList"
}
```

## 使用建议

- 用 ✅ 反应标记完成的任务
- 置顶关键决策或每周状态更新

---

*触发词：Slack、聊天、消息*
