---
name: notion
description: "Notion API用于创建和管理页面、数据库和块。"
---

# Notion技能

使用Notion API创建/读取/更新页面、数据源（数据库）和块。

## 设置

1. 在 https://notion.so/my-integrations 创建集成
2. 复制API密钥（以 `ntn_` 或 `secret_` 开头）
3. 存储：

```bash
mkdir -p ~/.config/notion
echo "ntn_your_key_here" > ~/.config/notion/api_key
```

4. 与你的集成共享目标页面/数据库（点击"..."→"连接到"→你的集成名称）

## 常用操作

**搜索页面和数据源：**

```bash
curl -X POST "https://api.notion.com/v1/search" \
  -H "Authorization: Bearer $NOTION_KEY" \
  -H "Notion-Version: 2025-09-03" \
  -H "Content-Type: application/json" \
  -d '{"query": "页面标题"}'
```

**获取页面：**

```bash
curl "https://api.notion.com/v1/pages/{page_id}" \
  -H "Authorization: Bearer $NOTION_KEY" \
  -H "Notion-Version: 2025-09-03"
```

**获取页面内容（块）：**

```bash
curl "https://api.notion.com/v1/blocks/{page_id}/children" \
  -H "Authorization: Bearer $NOTION_KEY" \
  -H "Notion-Version: 2025-09-03"
```

**在数据源中创建页面：**

```bash
curl -X POST "https://api.notion.com/v1/pages" \
  -H "Authorization: Bearer $NOTION_KEY" \
  -H "Notion-Version: 2025-09-03" \
  -H "Content-Type: application/json" \
  -d '{
    "parent": {"database_id": "xxx"},
    "properties": {
      "Name": {"title": [{"text": {"content": "新项目"}}]},
      "Status": {"select": {"name": "待办"}}
    }
  }'
```

## 属性类型

- **标题：** `{"title": [{"text": {"content": "..."}}]}`
- **富文本：** `{"rich_text": [{"text": {"content": "..."}}]}`
- **选择：** `{"select": {"name": "选项"}}`
- **多选：** `{"multi_select": [{"name": "A"}, {"name": "B"}]}`
- **日期：** `{"date": {"start": "2024-01-15", "end": "2024-01-16"}}`
- **复选框：** `{"checkbox": true}`
- **数字：** `{"number": 42}`
- **网址：** `{"url": "https://..."}`
- **邮箱：** `{"email": "a@b.com"}`

## 注意事项

- 页面/数据库ID是UUID（带或不带连字符）
- API无法设置数据库视图过滤器——那只能通过UI
- 速率限制：平均每秒约3个请求

---

*触发词：Notion、笔记、数据库*
