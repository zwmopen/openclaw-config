---
name: discord
description: "通过message工具进行Discord操作（channel=discord）。"
---

# Discord技能

使用 `message` 工具。没有暴露给代理的特定Discord工具。

## 必须项

- 始终使用：`channel: "discord"`
- 尊重权限：`channels.discord.actions.*`
- 优先使用明确ID：`guildId`、`channelId`、`messageId`、`userId`
- 多账户：可选 `accountId`

## 指南

- 避免在Discord消息中使用Markdown表格
- 提及用户：`<@USER_ID>`
- 富UI优先使用Discord组件v2（`components`）；仅在必要时使用旧版 `embeds`

## 目标

- 发送类操作：`to: "channel:<id>"` 或 `to: "user:<id>"`
- 消息特定操作：`channelId: "<id>"`（或 `to`）+ `messageId: "<id>"`

## 常用操作

**发送消息：**

```json
{
  "action": "send",
  "channel": "discord",
  "to": "channel:123",
  "message": "你好",
  "silent": true
}
```

**发送带媒体：**

```json
{
  "action": "send",
  "channel": "discord",
  "to": "channel:123",
  "message": "查看附件",
  "media": "file:///tmp/example.png"
}
```

**反应：**

```json
{
  "action": "react",
  "channel": "discord",
  "channelId": "123",
  "messageId": "456",
  "emoji": "✅"
}
```

**读取消息：**

```json
{
  "action": "read",
  "channel": "discord",
  "to": "channel:123",
  "limit": 20
}
```

**编辑/删除：**

```json
{
  "action": "edit",
  "channel": "discord",
  "channelId": "123",
  "messageId": "456",
  "message": "修正错字"
}
```

```json
{
  "action": "delete",
  "channel": "discord",
  "channelId": "123",
  "messageId": "456"
}
```

**投票：**

```json
{
  "action": "poll",
  "channel": "discord",
  "to": "channel:123",
  "pollQuestion": "午餐？",
  "pollOption": ["披萨", "寿司", "沙拉"],
  "pollMulti": false,
  "pollDurationHours": 24
}
```

**置顶：**

```json
{
  "action": "pin",
  "channel": "discord",
  "channelId": "123",
  "messageId": "456"
}
```

**帖子：**

```json
{
  "action": "thread-create",
  "channel": "discord",
  "channelId": "123",
  "messageId": "456",
  "threadName": "bug分类"
}
```

**搜索：**

```json
{
  "action": "search",
  "channel": "discord",
  "guildId": "999",
  "query": "发布说明",
  "channelIds": ["123", "456"],
  "limit": 10
}
```

## 写作风格（Discord）

- 短小、对话式、低仪式感
- 不用markdown表格
- 提及用户：`<@USER_ID>`

---

*触发词：Discord、聊天、消息*
