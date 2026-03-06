# OpenClaw启动顺序配置

## 用户需求

电脑启动 → OpenClaw启动 → CC Switch切换配置 → Claude启动

## 当前状态

- ✅ OpenClaw：开机自启动（Gateway端口18789）
- ✅ CC Switch：已配置（unicom-new profile）
- ❌ Claude Code：无法使用联通元景API（格式不兼容）

## 问题分析

### Claude Code的限制

Claude Code需要Anthropic API格式的响应，但联通元景API是OpenAI兼容格式。

**Claude Code期望**：
```json
{
  "content": [{"text": "Hello", "type": "text"}],
  "id": "msg_xxx",
  "model": "claude-3-5-sonnet-20241022",
  "role": "assistant",
  "type": "message"
}
```

**联通元景返回**：
```json
{
  "choices": [{"message": {"content": "Hello", "role": "assistant"}}],
  "model": "glm-5",
  "object": "chat.completion"
}
```

### 解决方案

#### 方案1：使用OpenClaw子代理

OpenClaw可以调用其他AI作为子代理，但需要：
1. 子代理支持OpenAI兼容格式
2. 或者搭建格式转换代理

#### 方案2：搭建Anthropic兼容代理

搭建一个代理服务器，监听15721端口：
1. 接收Claude Code的Anthropic格式请求
2. 转换为OpenAI格式
3. 发送到联通元景API
4. 转换响应为Anthropic格式
5. 返回给Claude Code

#### 方案3：使用OpenAI兼容的Claude客户端

使用支持OpenAI格式的Claude客户端，而不是Claude Code。

## 推荐方案

**方案2（搭建代理服务器）**：

创建一个简单的Node.js代理服务器：

```javascript
// proxy-server.js
const express = require('express');
const proxy = require('express-http-proxy');
const app = express();

// 转换Anthropic格式到OpenAI格式
app.use('/v1/messages', (req, res, next) => {
  // 转换逻辑
});

// 转发到联通元景API
app.use(proxy('https://maas-api.ai-yuanjing.com'));

app.listen(15721);
```

## 启动顺序脚本

```powershell
# startup.ps1

# 1. 启动OpenClaw Gateway（已自动启动）

# 2. 切换CC Switch配置
cc-switch unicom-new

# 3. 启动代理服务器（如果使用方案2）
# node proxy-server.js

# 4. （可选）启动Claude Code
# claude
```

## 下一步

1. 决定使用哪个方案
2. 如果选择方案2，我帮你搭建代理服务器
3. 如果选择方案3，我帮你找OpenAI兼容的Claude客户端
