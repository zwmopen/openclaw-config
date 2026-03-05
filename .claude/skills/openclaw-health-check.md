# OpenClaw网关自检技能

## 触发条件
- 用户问"网关是否正常"
- 用户问"检查一下"
- 用户说"自检"
- 用户说"有什么问题"

## 检查项目

### 1. 服务状态检查
```bash
# 检查端口占用
netstat -ano | findstr ":18789"
netstat -ano | findstr ":38789"

# 检查node进程
tasklist | findstr "node"
```

### 2. 日志分析
```bash
# 查看最新日志
Get-Content 'C:\Users\z\AppData\Local\Temp\openclaw\openclaw-*.log' -Tail 50

# 搜索错误
Select-String -Pattern 'error|401|failed|timeout|exception'

# 搜索飞书消息
Select-String -Pattern 'feishu.*dispatch|replies'
```

### 3. 配置检查
- openclaw.json 中的API Key是否正确
- 模型ID格式是否正确（联通元景需要 `/maas/glm-5`）
- 飞书配置是否正确

### 4. 常见问题诊断

| 症状 | 可能原因 | 解决方案 |
|------|----------|----------|
| replies=0 | 模型调用失败 | 检查API Key和模型ID |
| 401错误 | 认证失败 | 检查API Key是否正确 |
| 连接断开 | WebSocket断开 | 重启网关 |
| 消息重复 | 飞书重推 | 正常，忽略 |
| 超时 | 模型响应慢 | 切换更快的模型 |

### 5. 修复命令

**重启网关（卡死时）：**
```powershell
# 1. 杀掉node进程
Get-Process -Name node | Stop-Process -Force

# 2. 清理会话锁
Remove-Item -Path '.openclaw\agents\main\sessions\*' -Recurse -Force

# 3. 重启网关
powershell -NoExit -ExecutionPolicy Bypass -File "scripts\start-gateway.ps1"
node "panel\server.js"
```

## 输出格式

```
## 🔍 OpenClaw自检报告

### 服务状态
| 项目 | 状态 |
|------|------|
| 网关 | ✅/❌ |
| 飞书连接 | ✅/❌ |
| 消息回复 | ✅/❌ |

### 日志分析
- 最近消息数：X条
- 成功回复：X条
- 失败回复：X条

### 发现问题
1. 问题描述
   - 解决方案

### 建议
- 优化建议
```

## 记忆更新
每次自检后，将发现的问题和解决方案更新到TRAE-MEMORY.md
