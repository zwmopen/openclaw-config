---
name: trello
description: "通过Trello REST API管理Trello看板、列表和卡片。"
---

# Trello技能

直接从OpenClaw管理Trello看板、列表和卡片。

## 设置

1. 获取API密钥：https://trello.com/app-key
2. 生成令牌（点击该页面上的"Token"链接）
3. 设置环境变量：
   ```bash
   export TRELLO_API_KEY="your-api-key"
   export TRELLO_TOKEN="your-token"
   ```

## 使用方法

所有命令使用curl调用Trello REST API。

### 列出看板

```bash
curl -s "https://api.trello.com/1/members/me/boards?key=$TRELLO_API_KEY&token=$TRELLO_TOKEN" | jq '.[] | {name, id}'
```

### 列出看板中的列表

```bash
curl -s "https://api.trello.com/1/boards/{boardId}/lists?key=$TRELLO_API_KEY&token=$TRELLO_TOKEN" | jq '.[] | {name, id}'
```

### 列出列表中的卡片

```bash
curl -s "https://api.trello.com/1/lists/{listId}/cards?key=$TRELLO_API_KEY&token=$TRELLO_TOKEN" | jq '.[] | {name, id, desc}'
```

### 创建卡片

```bash
curl -s -X POST "https://api.trello.com/1/cards?key=$TRELLO_API_KEY&token=$TRELLO_TOKEN" \
  -d "idList={listId}" \
  -d "name=卡片标题" \
  -d "desc=卡片描述"
```

### 移动卡片到另一个列表

```bash
curl -s -X PUT "https://api.trello.com/1/cards/{cardId}?key=$TRELLO_API_KEY&token=$TRELLO_TOKEN" \
  -d "idList={newListId}"
```

### 给卡片添加评论

```bash
curl -s -X POST "https://api.trello.com/1/cards/{cardId}/actions/comments?key=$TRELLO_API_KEY&token=$TRELLO_TOKEN" \
  -d "text=你的评论"
```

### 归档卡片

```bash
curl -s -X PUT "https://api.trello.com/1/cards/{cardId}?key=$TRELLO_API_KEY&token=$TRELLO_TOKEN" \
  -d "closed=true"
```

## 注意事项

- 看板/列表/卡片ID可以在Trello URL中找到或通过列表命令获取
- API密钥和令牌提供对你Trello账户的完全访问权限——保密！
- 速率限制：每个API密钥每10秒300个请求；每个令牌每10秒100个请求；`/1/members`端点限制为每900秒100个请求

---

*触发词：Trello、看板、任务管理*
