# OpenClaw 完整使用指南

## 一、快速开始

### 1.1 环境要求
- Node.js 版本 >= 22.12.0
- 已安装 OpenClaw
- 硅基流动API密钥
- 飞书机器人配置信息

### 1.2 启动 OpenClaw

在 `d:\AI编程\openclaw` 目录下运行：

```bash
# 查看帮助信息
./openclaw.bat --help

# 初始化配置（首次使用）
./openclaw.bat setup

# 启动网关
./openclaw.bat gateway --port 18789

# 打开控制面板
./openclaw.bat dashboard
```

### 1.3 当前配置状态
✅ OpenClaw已初始化
✅ 网关已启动：ws://127.0.0.1:18789
✅ 访问令牌：`71bd6f4031391006fb6b75ed1866fd11a4d9863cdd4592bb`

## 二、配置硅基流动模型

### 2.1 硅基流动简介
硅基流动是一个AI模型服务平台，提供多种大语言模型API服务，包括：
- DeepSeek系列模型
- Qwen系列模型
- GLM系列模型
- 其他开源模型

### 2.2 配置方法

#### 方法一：使用环境变量
```bash
# 设置硅基流动API密钥
set SILICONFLOW_API_KEY=sk-hyaakxkupozeqeisekcvnvterzifvgcjconbghtmxgrjufke

# 启动网关
./openclaw.bat gateway
```

#### 方法二：使用配置文件
编辑配置文件 `~/.openclaw/openclaw.json`，添加：

```json
{
  "providers": {
    "siliconflow": {
      "apiKey": "sk-hyaakxkupozeqeisekcvnvterzifvgcjconbghtmxgrjufke",
      "baseUrl": "https://api.siliconflow.cn/v1"
    }
  },
  "agent": {
    "model": "siliconflow/deepseek-chat"
  }
}
```

### 2.3 可用模型列表
- `deepseek-chat` - 通用对话模型
- `deepseek-coder` - 代码专用模型
- `Qwen/Qwen2.5-7B-Instruct` - 通义千问
- `THUDM/glm-4-9b-chat` - 智谱GLM

## 三、配置飞书机器人

### 3.1 创建飞书应用
详细步骤请参考：[飞书机器人配置指南.md](./飞书机器人配置指南.md)

### 3.2 必需权限清单
- `im:message` - 获取与发送消息
- `im:message:send_as_bot` - 以应用身份发消息
- `im:message:receive_as_bot` - 接收@机器人消息
- `im:chat` - 获取群组信息
- `contact:user.base:readonly` - 获取用户基本信息

### 3.3 配置步骤
```bash
# 添加飞书渠道
./openclaw.bat channels add --channel feishu \
  --app-id cli_xxxxxxxxxxxx \
  --app-secret xxxxxxxxxxxxxxxx \
  --verification-token xxxxxxxxxxxxxxxx

# 查看渠道状态
./openclaw.bat channels status

# 启动机器人服务
./openclaw.bat gateway
```

## 四、Token优化省钱指南

基于《OpenClaw从月烧到月花10的完整攻略》，以下是优化Token使用的核心策略：

### 4.1 模型选择策略

#### 按任务复杂度选择模型
| 任务类型 | 推荐模型 | Token消耗 |
|---------|---------|----------|
| 简单问答 | deepseek-chat | 低 |
| 代码生成 | deepseek-coder | 中 |
| 复杂推理 | deepseek-chat | 高 |
| 文档分析 | Qwen2.5-7B | 中 |

#### 模型参数优化
```json
{
  "agent": {
    "model": "siliconflow/deepseek-chat",
    "temperature": 0.3,
    "maxTokens": 2000,
    "topP": 0.9
  }
}
```

**参数说明：**
- `temperature`: 0.3-0.5，降低随机性，提高回复质量
- `maxTokens`: 限制最大输出，避免冗长回复
- `topP`: 0.9，控制采样范围

### 4.2 提示词优化技巧

#### 精确指令模板
```
【角色】你是一个专业的AI助手
【任务】回答用户问题
【要求】
1. 回答简洁明了
2. 不重复问题
3. 直接给出答案
【输出格式】纯文本，无markdown
```

#### 结构化提示示例
```
任务：[具体任务]
输入：[用户输入]
输出要求：
- 格式：[格式要求]
- 长度：[字数限制]
- 风格：[风格要求]
```

### 4.3 上下文管理

#### 启用上下文剪枝
```json
{
  "agents": {
    "defaults": {
      "contextPruning": {
        "mode": "cache-ttl",
        "ttl": "1h"
      },
      "compaction": {
        "mode": "safeguard"
      }
    }
  }
}
```

#### 对话摘要策略
- 定期对长对话进行摘要
- 保留关键信息，删除冗余内容
- 设置对话轮次上限（如20轮）

### 4.4 监控与分析

#### 启用Token统计
```bash
# 查看使用统计
./openclaw.bat status --deep

# 查看日志
./openclaw.bat logs
```

#### 成本监控指标
- 每日Token消耗量
- 平均每次对话Token数
- 模型调用频率
- 错误率统计

### 4.5 高级优化技巧

#### 批量处理
将多个相似任务合并处理：
```
任务：分析以下5个问题
1. [问题1]
2. [问题2]
3. [问题3]
...
一次性输出所有答案
```

#### 缓存策略
- 启用响应缓存
- 相同问题直接返回缓存结果
- 设置缓存过期时间

#### 流式输出
```json
{
  "agent": {
    "stream": true
  }
}
```
- 实时返回结果
- 减少等待时间
- 提升用户体验

## 五、常用命令速查

### 5.1 网关管理
```bash
# 启动网关
./openclaw.bat gateway --port 18789

# 强制重启网关
./openclaw.bat gateway --force

# 查看网关状态
./openclaw.bat health

# 查看日志
./openclaw.bat logs
```

### 5.2 渠道管理
```bash
# 列出所有渠道
./openclaw.bat channels list

# 查看渠道状态
./openclaw.bat channels status

# 添加渠道
./openclaw.bat channels add --channel <渠道名>

# 移除渠道
./openclaw.bat channels remove --channel <渠道名>
```

### 5.3 模型管理
```bash
# 列出可用模型
./openclaw.bat models list

# 测试模型连接
./openclaw.bat models test --model deepseek-chat
```

### 5.4 配置管理
```bash
# 查看当前配置
./openclaw.bat config get

# 设置配置项
./openclaw.bat config set <key> <value>

# 重置配置
./openclaw.bat reset
```

## 六、故障排除

### 6.1 常见问题

#### Node.js版本问题
```
错误：openclaw requires Node >=22.12.0
解决：使用正确的Node.js版本
```

#### 网关启动失败
```
错误：Gateway start blocked
解决：运行 ./openclaw.bat config set gateway.mode local
```

#### API密钥错误
```
错误：Invalid API key
解决：检查硅基流动API密钥是否正确
```

#### 飞书连接失败
```
错误：Channel connection failed
解决：检查飞书应用配置和权限
```

### 6.2 日志分析
```bash
# 查看详细日志
./openclaw.bat logs --verbose

# 查看错误日志
./openclaw.bat logs --level error

# 实时监控日志
./openclaw.bat logs --follow
```

## 七、最佳实践

### 7.1 安全建议
- 不要在代码中硬编码API密钥
- 使用环境变量存储敏感信息
- 定期更换访问令牌
- 限制IP访问白名单

### 7.2 性能优化
- 启用响应缓存
- 使用流式输出
- 合理设置超时时间
- 监控资源使用情况

### 7.3 成本控制
- 选择合适的模型
- 优化提示词
- 启用上下文剪枝
- 设置使用限额

## 八、进阶功能

### 8.1 自定义技能
```bash
# 查看可用技能
./openclaw.bat skills list

# 添加自定义技能
./openclaw.bat skills add --name <技能名>
```

### 8.2 Webhook集成
```bash
# 配置Webhook
./openclaw.bat webhooks add --url <webhook地址>
```

### 8.3 多渠道管理
OpenClaw支持多种渠道：
- 飞书
- 钉钉
- 企业微信
- Telegram
- Discord

## 九、配置文件参考

### 9.1 完整配置示例
```json
{
  "meta": {
    "lastTouchedVersion": "2026.2.21-2"
  },
  "agents": {
    "defaults": {
      "workspace": "~/.openclaw/workspace",
      "contextPruning": {
        "mode": "cache-ttl",
        "ttl": "1h"
      },
      "compaction": {
        "mode": "safeguard"
      },
      "heartbeat": {
        "every": "30m"
      }
    }
  },
  "gateway": {
    "mode": "local",
    "auth": {
      "mode": "token",
      "token": "your-token-here"
    }
  },
  "providers": {
    "siliconflow": {
      "apiKey": "sk-hyaakxkupozeqeisekcvnvterzifvgcjconbghtmxgrjufke",
      "baseUrl": "https://api.siliconflow.cn/v1"
    }
  },
  "agent": {
    "model": "siliconflow/deepseek-chat",
    "temperature": 0.3,
    "maxTokens": 2000
  }
}
```

## 十、总结

OpenClaw是一个强大的AI自动化平台，通过合理配置可以：
- 降低Token使用成本
- 提高响应效率
- 实现多渠道集成
- 自动化工作流程

**关键优化点：**
1. 选择合适的模型和参数
2. 优化提示词结构
3. 启用上下文管理
4. 监控使用情况
5. 定期调整策略

**下一步行动：**
1. 完成飞书机器人配置
2. 测试硅基流动模型连接
3. 部署到生产环境
4. 监控和优化

如有问题，请参考官方文档：https://docs.openclaw.ai
