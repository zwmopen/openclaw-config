# Claude Code代理配置方案

## 问题

CC Switch配置指向 `http://127.0.0.1:15721`，但没有代理服务器在运行。

## 解决方案

### 方案1：修改CC Switch配置，直接指向联通元景API

```json
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "sk-33b2451706fb4098850b14a9dfbb5827",
    "ANTHROPIC_BASE_URL": "https://maas-api.ai-yuanjing.com/openapi/compatible-mode/v1"
  }
}
```

### 方案2：使用OpenClaw Gateway作为代理

OpenClaw Gateway端口：18789

修改CC Switch配置：
```json
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "2d65353ea3422e1bd863c865f7cc9b3d92514be0fd19ebd8",
    "ANTHROPIC_BASE_URL": "http://127.0.0.1:18789"
  }
}
```

### 方案3：搭建专用代理服务器

使用Node.js搭建一个简单的代理服务器，监听15721端口，转发请求到联通元景API。

## 推荐

**方案1最简单**：直接修改CC Switch配置，指向联通元景API。

## Claude Code的限制

Claude Code需要Anthropic API格式的响应，但联通元景API是OpenAI兼容格式。

可能需要格式转换代理服务器。

## 下一步

1. 尝试方案1（直接指向联通元景API）
2. 如果不工作，尝试方案3（搭建代理服务器）
