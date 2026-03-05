# OpenClaw飞书机器人自动化部署指南

> 本文档专为AI编程软件设计，读取后可自动执行部署操作。

---

## 前置条件检查

### 必需环境
- [ ] Node.js >= 22 已安装
- [ ] npm 已安装
- [ ] Windows操作系统

### 必需账号
- [ ] 硅基流动账号 (https://cloud.siliconflow.cn)
- [ ] 飞书开发者账号 (https://open.feishu.cn)

### 必需信息
- [ ] 硅基流动API密钥 (格式: sk-xxx)
- [ ] 飞书App ID (格式: cli_xxx)
- [ ] 飞书App Secret

---

## 第一阶段：安装OpenClaw

### 步骤1.1：安装OpenClaw
```bash
npm i -g openclaw
```

### 步骤1.2：运行初始化向导
```bash
openclaw onboard --install-daemon
```

### 步骤1.3：安装飞书SDK依赖（关键！）
```bash
npm install -g @larksuiteoapi/node-sdk
```

### 步骤1.4：创建SDK符号链接（Windows必需！）

**问题：** 飞书插件会报错 `Cannot find module '@larksuiteoapi/node-sdk'`

**解决方案：** 创建junction链接

```powershell
# 查找OpenClaw安装路径
$openclawPath = (Get-Command openclaw).Source | Split-Path | Split-Path
Write-Host "OpenClaw路径: $openclawPath"

# 创建junction链接
$sdkSource = "$env:APPDATA\npm\node_modules\@larksuiteoapi"
$sdkTarget = "$openclawPath\node_modules\@larksuiteoapi"

if (Test-Path $sdkSource) {
    New-Item -ItemType Junction -Path $sdkTarget -Target $sdkSource -Force
    Write-Host "SDK链接创建成功"
} else {
    Write-Host "错误：SDK未正确安装"
}
```

---

## 第二阶段：创建飞书应用

### 步骤2.1：创建应用
1. 访问 https://open.feishu.cn/app
2. 点击"创建企业自建应用"
3. 填写应用名称（如：OpenClaw助手）
4. 点击"创建"

### 步骤2.2：记录凭证
创建完成后，记录以下信息：
- **App ID**: cli_xxxxxxxx
- **App Secret**: xxxxxxxx

### 步骤2.3：添加权限（关键！）

**问题：** 不添加权限会导致 `HTTP 403: forbidden` 错误

#### 方法一：JSON批量导入（推荐）

1. 点击左侧"权限管理"
2. 找到 **"批量导入"** 或 **"导入权限配置"** 按钮
3. 粘贴以下JSON内容：

> ⚠️ **重要提示**：必须是**单行紧凑格式**，不能有换行和多余空格！直接复制下面这一行：

```
{"scopes": {"tenant": ["contact:contact.base:readonly","contact:user.base:readonly","contact:user.employee_id:readonly","im:message","im:message.group_at_msg:readonly","im:message.p2p_msg:readonly","im:message:send_as_bot","im:message:receive_as_bot","im:chat","im:chat:readonly","im:chat.member:readonly","im:resource"],"user": []}}
```

4. 点击"下一步" → "确认新增" → "申请开通"

#### 方法二：手动添加权限

**必需权限列表：**
```
im:message                      - 获取与发送单聊、群组消息
im:message:send_as_bot          - 以应用身份发消息
im:message:receive_as_bot       - 接收群聊中@机器人消息
im:chat                         - 获取群组信息
im:chat:readonly                - 获取群组信息（只读）
im:chat.member:readonly         - 获取群成员列表
contact:contact.base:readonly   - 获取通讯录基本信息（关键！）
contact:user.base:readonly      - 获取用户基本信息
contact:user.employee_id:readonly - 获取用户员工ID
im:resource                     - 获取与上传图片或文件
```

**权限类型说明：**
- **tenant权限（应用身份）**：应用以自己的身份访问数据，适合机器人场景
- **user权限（用户身份）**：应用代表用户访问数据，需要用户授权

**操作步骤：**
1. 点击左侧"权限管理"
2. 搜索上述权限名称
3. 点击"添加权限"或"申请权限"
4. 确认添加

### 步骤2.4：配置事件订阅（关键！）

**问题：** 选择错误的订阅方式会导致机器人收不到消息

**正确配置：**
1. 点击左侧"事件与回调"
2. **订阅方式**选择：**"使用长连接接收事件"**（不是"将事件发送至开发者服务器"！）
3. 点击"添加事件"
4. 搜索并添加：`im.message.receive_v1`
5. 点击"保存"

### 步骤2.5：启用机器人功能
1. 点击左侧"应用功能" -> "机器人"
2. 开启"启用机器人"
3. 设置机器人名称和头像

### 步骤2.6：发布应用
1. 点击左侧"版本管理与发布"
2. 点击"创建版本"
3. 填写版本号（如：1.0.0）
4. 点击"保存"
5. 点击"申请发布"
6. 等待发布成功

**注意：** 每次修改权限都需要重新发布版本！

---

## 第三阶段：配置OpenClaw

### 步骤3.1：配置飞书渠道
```bash
openclaw config set -- channels.feishu.appId "YOUR_APP_ID"
openclaw config set -- channels.feishu.appSecret "YOUR_APP_SECRET"
```

### 步骤3.2：配置硅基流动模型（一键命令）
```bash
openclaw onboard --non-interactive --auth-choice custom-api-key --custom-base-url "https://api.siliconflow.cn/v1" --custom-model-id "deepseek-ai/DeepSeek-V3" --custom-api-key "YOUR_SILICONFLOW_API_KEY" --custom-compatibility openai --accept-risk
```

### 步骤3.3：设置模型上下文窗口（关键！）

**问题：** 默认上下文窗口太小会导致 `Model context window too small` 错误

```bash
openclaw config set -- models.providers.custom-api-siliconflow-cn.models.0.contextWindow 128000
```

### 步骤3.4：配置工作目录
```bash
openclaw config set -- agents.defaults.workspace "YOUR_WORKSPACE_PATH"
```

### 步骤3.5：启用Token优化（可选但推荐）
```bash
openclaw config set -- agents.defaults.contextPruning.mode "cache-ttl"
openclaw config set -- agents.defaults.contextPruning.ttl "1h"
openclaw config set -- agents.defaults.compaction.mode "safeguard"
openclaw config set -- hooks.internal.entries.session-memory.enabled true
```

---

## 第四阶段：启动网关

### 步骤4.1：启动网关
```bash
openclaw gateway
```

### 步骤4.2：验证启动成功
检查日志中是否包含：
```
[gateway] listening on ws://127.0.0.1:18789
[feishu] feishu[main]: WebSocket client started
[info]: [ '[ws]', 'ws client ready' ]
```

---

## 第五阶段：测试机器人

### 步骤5.1：群聊测试
1. 在飞书群聊中添加机器人
2. 发送：`@机器人名称 你好`
3. 机器人应该回复

### 步骤5.2：私信测试
1. 在飞书搜索机器人名称
2. 进入对话
3. 发送：`你好`
4. 机器人应该回复

---

## 常见错误及解决方案

### 调试工具

飞书开放平台提供以下调试工具：
1. **API调试工具**：在"开发调试" -> "API调试"中测试API调用
2. **事件推送测试**：在"事件与回调"中模拟事件推送
3. **日志查看**：在"监控与告警"中查看API调用日志和错误日志

### 错误1：飞书插件加载失败
```
[plugins] feishu failed to load: Error: Cannot find module '@larksuiteoapi/node-sdk'
```

**原因：** 飞书SDK未安装或未正确链接

**解决方案：**
```bash
# 1. 安装SDK
npm install -g @larksuiteoapi/node-sdk

# 2. 创建junction链接
$openclawPath = (Get-Command openclaw).Source | Split-Path | Split-Path
New-Item -ItemType Junction -Path "$openclawPath\node_modules\@larksuiteoapi" -Target "$env:APPDATA\npm\node_modules\@larksuiteoapi" -Force

# 3. 重启网关
openclaw gateway
```

---

### 错误2：权限拒绝 (99991672)
```
HTTP 403: forbidden: Request not allowed
code: 99991672 - Access denied. scopes required: [contact:contact.base:readonly]
```

**原因：** 缺少通讯录权限

**解决方案：**
1. 飞书开放平台 -> 权限管理
2. 添加 `contact:contact.base:readonly` 权限
3. 创建新版本并发布
4. 等待5分钟
5. 重启OpenClaw网关

---

### 错误3：未知模型
```
Agent failed before reply: Unknown model: siliconflow/deepseek-ai/DeepSeek-V3
```

**原因：** 模型provider未正确配置

**解决方案：**
```bash
openclaw onboard --non-interactive --auth-choice custom-api-key --custom-base-url "https://api.siliconflow.cn/v1" --custom-model-id "deepseek-ai/DeepSeek-V3" --custom-api-key "YOUR_API_KEY" --custom-compatibility openai --accept-risk
```

---

### 错误4：上下文窗口太小
```
Agent failed before reply: Model context window too small (4096 tokens). Minimum is 16000.
```

**原因：** 默认上下文窗口配置不足

**解决方案：**
```bash
openclaw config set -- models.providers.custom-api-siliconflow-cn.models.0.contextWindow 128000
```

---

### 错误5：机器人不回复消息
**症状：** 网关正常启动，但机器人不响应

**可能原因及解决方案：**

1. **订阅方式错误**
   - 检查：事件与回调 -> 订阅方式
   - 必须是：**"使用长连接接收事件"**
   - 不能是："将事件发送至开发者服务器"

2. **事件未添加**
   - 检查：事件与回调 -> 已添加事件
   - 必须有：`im.message.receive_v1`

3. **权限未发布**
   - 每次修改权限后必须发布新版本

4. **等待时间不够**
   - 发布后等待5-10分钟

---

### 错误6：配置验证失败
```
Error: Config validation failed: models.providers.siliconflow.baseUrl
```

**原因：** 使用 `config set` 单独设置模型参数时顺序错误

**解决方案：** 使用 `onboard` 命令一次性配置，不要单独设置

---

### 错误7：网关令牌不匹配
```
gateway closed (1008): unauthorized: device token mismatch
```

**原因：** 配置更改后设备配对问题

**解决方案：**
```bash
# 重启网关即可自动修复
openclaw gateway
```

---

### 错误8：权限申请待审批
**症状：** 权限添加后一直显示"待审批"

**原因：** 部分敏感权限需要管理员审批

**解决方案：**
1. 联系飞书管理员
2. 在管理后台审批权限申请

---

### 错误9：机器人无法发送图片/文件
**症状：** 文件上传失败

**原因：** 缺少 `im:resource` 权限

**解决方案：**
1. 添加 `im:resource` 权限
2. 发布新版本

---

## 完整配置文件参考

最终 `~/.openclaw/openclaw.json` 结构：

```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "custom-api-siliconflow-cn/deepseek-ai/DeepSeek-V3"
      },
      "workspace": "YOUR_WORKSPACE_PATH",
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
  "channels": {
    "feishu": {
      "enabled": true,
      "appId": "cli_xxx",
      "appSecret": "xxx",
      "dmPolicy": "open"
    }
  },
  "models": {
    "providers": {
      "custom-api-siliconflow-cn": {
        "api": "openai",
        "baseUrl": "https://api.siliconflow.cn/v1",
        "apiKey": "sk-xxx",
        "models": [
          {
            "id": "deepseek-ai/DeepSeek-V3",
            "contextWindow": 128000
          }
        ]
      }
    }
  },
  "hooks": {
    "internal": {
      "entries": {
        "session-memory": {
          "enabled": true
        }
      }
    }
  },
  "plugins": {
    "entries": {
      "feishu": {
        "enabled": true
      }
    }
  }
}
```

---

## 备用模型配置

OpenClaw支持配置多个模型提供商，当主力模型不可用时可以快速切换。

### 当前配置的模型提供商

| 提供商 | 模型 | 状态 | 说明 |
|--------|------|------|------|
| 联通元景 | GLM-5 | 🟢 当前使用 | 主力模型 |
| 硅基流动 | DeepSeek-V3 | 🟡 备用 | 高性价比 |
| 智谱AI | GLM-4-Flash | 🟡 备用 | 免费额度 |

### 模型API配置

```json
{
  "unicom": {
    "baseUrl": "https://maas-api.ai-yuanjing.com/openapi/compatible-mode/v1",
    "apiKey": "sk-xxx",
    "api": "openai-completions",
    "models": [{ "id": "glm-5", "name": "GLM-5 (联通元景)" }]
  },
  "custom-api-siliconflow-cn": {
    "baseUrl": "https://api.siliconflow.cn/v1",
    "apiKey": "sk-xxx",
    "api": "openai-completions",
    "models": [{ "id": "deepseek-ai/DeepSeek-V3", "name": "DeepSeek-V3" }]
  },
  "zhipu-official": {
    "baseUrl": "https://open.bigmodel.cn/api/paas/v4/",
    "apiKey": "xxx",
    "api": "openai-completions",
    "models": [{ "id": "glm-4-flash", "name": "GLM-4-Flash" }]
  }
}
```

### 切换模型

```bash
# 切换到联通元景GLM-5（当前主力）
openclaw config set -- agents.defaults.model.primary "unicom/glm-5"

# 切换到硅基流动DeepSeek
openclaw config set -- agents.defaults.model.primary "custom-api-siliconflow-cn/deepseek-ai/DeepSeek-V3"

# 切换到智谱GLM-4-Flash
openclaw config set -- agents.defaults.model.primary "zhipu-official/glm-4-flash"
```

### 凭证管理

所有API密钥保存在配置文件中，便于管理：

**默认配置路径：** `C:\Users\{用户名}\.openclaw\openclaw.json`

**自定义配置路径（推荐）：**

OpenClaw支持通过环境变量自定义配置路径：

```powershell
# 设置配置目录
$env:OPENCLAW_STATE_DIR = "D:\AI编程\openclaw\.openclaw"

# 设置配置文件路径
$env:OPENCLAW_CONFIG_PATH = "D:\AI编程\openclaw\.openclaw\openclaw.json"

# 启动网关
openclaw gateway
```

**启动脚本示例（保存为 start-gateway.ps1）：**

```powershell
# OpenClaw Gateway Launcher
$env:OPENCLAW_STATE_DIR = "D:\AI编程\openclaw\.openclaw"
$env:OPENCLAW_CONFIG_PATH = "D:\AI编程\openclaw\.openclaw\openclaw.json"

$nodeExe = "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node.exe"
$openclawMjs = "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node_modules\openclaw\openclaw.mjs"

& $nodeExe $openclawMjs $args
```

---

## 快速命令参考

| 命令 | 说明 |
|------|------|
| `openclaw gateway` | 启动网关 |
| `openclaw logs` | 查看日志 |
| `openclaw doctor` | 检查配置 |
| `openclaw doctor --fix` | 自动修复配置问题 |
| `openclaw config get` | 查看当前配置 |
| `openclaw config set -- <path> <value>` | 设置配置项 |

---

## 部署检查清单

### 安装阶段
- [ ] Node.js >= 22 已安装
- [ ] OpenClaw已全局安装
- [ ] 飞书SDK已安装
- [ ] SDK junction链接已创建

### 飞书配置阶段
- [ ] 应用已创建
- [ ] App ID和Secret已记录
- [ ] 所有权限已添加
- [ ] 事件订阅已配置（长连接模式）
- [ ] im.message.receive_v1事件已添加
- [ ] 机器人功能已启用
- [ ] 应用已发布

### OpenClaw配置阶段
- [ ] 飞书渠道已配置
- [ ] 模型已配置（GLM-5/DeepSeek-V3）
- [ ] 上下文窗口已设置为128000
- [ ] 工作目录已配置
- [ ] Token优化已启用
- [ ] 飞书allowFrom已配置

### 测试阶段
- [ ] 网关启动成功
- [ ] 飞书WebSocket连接成功
- [ ] 群聊@机器人测试通过
- [ ] 私信测试通过

---

## 关键注意事项

1. **长连接模式**：必须选择"使用长连接接收事件"，否则收不到消息
2. **权限发布**：每次修改权限必须发布新版本
3. **SDK链接**：Windows必须创建junction链接
4. **上下文窗口**：必须设置为128000或更高
5. **群聊@提及**：群聊中必须@机器人才会触发回复
6. **等待时间**：发布后等待5-10分钟让配置生效
7. **使用onboard**：配置模型用onboard命令，不要单独config set
8. **重启网关**：任何配置修改后都要重启网关
9. **飞书allowFrom**：必须配置 `channels.feishu.allowFrom: ["*"]` 才能接收消息
10. **自定义配置路径**：使用环境变量 `OPENCLAW_CONFIG_PATH` 自定义配置文件位置

---

## 云服务器部署

### 联通云服务器信息

| 配置项 | 值 |
|--------|-----|
| 公网IP | `116.176.77.165` |
| SSH端口 | 22 |
| SSH密码 | `147258AA@s` |
| VNC密码 | `147258AA` |
| 到期时间 | 2026-04-01 |

### 连接方式

**SSH连接：**
```bash
ssh root@116.176.77.165
# 密码: 147258AA@s
```

**VNC连接：**
1. 登录联通云控制台: https://console.unicomcloud.cn/
2. 进入云服务器ECS → 找到实例
3. 点击远程连接 → VNC远程连接
4. 输入VNC密码: `147258AA`

### 服务器用途

- 远程部署OpenClaw网关
- 公网访问：`http://116.176.77.165:18789`
- 备份和灾备

---

## 一键部署脚本

将以下内容保存为 `deploy-openclaw-feishu.ps1`：

```powershell
# OpenClaw飞书机器人一键部署脚本

param(
    [Parameter(Mandatory=$true)]
    [string]$FeishuAppId,
    
    [Parameter(Mandatory=$true)]
    [string]$FeishuAppSecret,
    
    [Parameter(Mandatory=$true)]
    [string]$SiliconflowApiKey,
    
    [string]$WorkspacePath = "D:\"
)

Write-Host "=== OpenClaw飞书机器人部署脚本 ===" -ForegroundColor Green

# 1. 安装OpenClaw
Write-Host "`n[1/6] 安装OpenClaw..." -ForegroundColor Yellow
npm i -g openclaw

# 2. 安装飞书SDK
Write-Host "`n[2/6] 安装飞书SDK..." -ForegroundColor Yellow
npm install -g @larksuiteoapi/node-sdk

# 3. 创建SDK链接
Write-Host "`n[3/6] 创建SDK链接..." -ForegroundColor Yellow
$openclawPath = (Get-Command openclaw).Source | Split-Path | Split-Path
$sdkSource = "$env:APPDATA\npm\node_modules\@larksuiteoapi"
$sdkTarget = "$openclawPath\node_modules\@larksuiteoapi"
if (Test-Path $sdkSource) {
    New-Item -ItemType Junction -Path $sdkTarget -Target $sdkSource -Force
}

# 4. 配置飞书渠道
Write-Host "`n[4/6] 配置飞书渠道..." -ForegroundColor Yellow
openclaw config set -- channels.feishu.appId $FeishuAppId
openclaw config set -- channels.feishu.appSecret $FeishuAppSecret

# 5. 配置硅基流动模型
Write-Host "`n[5/6] 配置硅基流动模型..." -ForegroundColor Yellow
openclaw onboard --non-interactive --auth-choice custom-api-key --custom-base-url "https://api.siliconflow.cn/v1" --custom-model-id "deepseek-ai/DeepSeek-V3" --custom-api-key $SiliconflowApiKey --custom-compatibility openai --accept-risk

# 6. 设置上下文窗口和工作目录
Write-Host "`n[6/6] 完成配置..." -ForegroundColor Yellow
openclaw config set -- models.providers.custom-api-siliconflow-cn.models.0.contextWindow 128000
openclaw config set -- agents.defaults.workspace $WorkspacePath
openclaw config set -- agents.defaults.contextPruning.mode "cache-ttl"
openclaw config set -- agents.defaults.compaction.mode "safeguard"

Write-Host "`n=== 部署完成！===" -ForegroundColor Green
Write-Host "请运行 'openclaw gateway' 启动网关" -ForegroundColor Cyan
Write-Host "`n重要提醒：" -ForegroundColor Yellow
Write-Host "1. 请在飞书开放平台配置事件订阅（长连接模式）" -ForegroundColor White
Write-Host "2. 请添加 im.message.receive_v1 事件" -ForegroundColor White
Write-Host "3. 请添加所有必需权限并发布版本" -ForegroundColor White
Write-Host "4. 群聊中需要@机器人才会回复" -ForegroundColor White
```

**使用方法：**
```powershell
.\deploy-openclaw-feishu.ps1 -FeishuAppId "cli_xxx" -FeishuAppSecret "xxx" -SiliconflowApiKey "sk-xxx" -WorkspacePath "D:\Your\Path"
```

---

## 安全配置指南

### 安全状态检查

运行以下命令检查当前安全状态：
```powershell
# 检查配置
.\openclaw.bat doctor

# 查看当前配置
.\openclaw.bat config get
```

### 关键安全配置项

| 配置项 | 安全值 | 说明 |
|--------|--------|------|
| `gateway.bind` | `loopback` | 只绑定本地127.0.0.1，禁止公网访问 |
| `gateway.auth.mode` | `token` | 启用token认证 |
| `agents.defaults.workspace` | 专用目录 | 限制文件访问范围 |

### 加固配置文件权限

```powershell
# 限制配置文件权限，只允许当前用户访问
icacls "C:\Users\z\.openclaw\openclaw.json" /inheritance:r /grant:r "$env:USERNAME:F"
```

### 禁用高危工具（可选）

如果不需要执行Shell命令，建议禁用：
```powershell
.\openclaw.bat config set -- tools.elevated.enabled false
```

---

## 启动/停止开关

### 方法一：可视化控制面板（推荐）

双击运行 `启动控制面板.ps1`，会自动打开浏览器控制面板：

**功能特点：**
- 🚀 一键启动/停止 OpenClaw
- 📊 实时状态监控
- 🔒 安全状态检查
- 🔄 一键检查更新
- 📋 操作日志记录

**访问地址：** http://localhost:8080

### 方法二：命令行开关脚本

```powershell
# 启动OpenClaw
.\openclaw-switch.ps1 -Action start

# 停止OpenClaw
.\openclaw-switch.ps1 -Action stop

# 查看状态
.\openclaw-switch.ps1 -Action status

# 重启
.\openclaw-switch.ps1 -Action restart
```

### 远程控制（向日葵）

1. 通过向日葵远程连接到电脑
2. 打开PowerShell，进入目录：`cd D:\AI编程\openclaw`
3. 运行启动/停止命令

---

## 自动更新配置

### 创建开机自动更新任务（每天一次）

脚本会自动记录运行日期，**每天只运行一次**，同一天多次开机会自动跳过。

```powershell
# 以管理员身份运行PowerShell，然后执行：
.\setup-auto-update.ps1
```

**特点：**
- 每天开机后自动运行一次
- 同一天多次开机会自动跳过
- 有网络时才运行
- 后台静默运行

### 手动检查更新

```powershell
# 检查并更新
.\update-openclaw.ps1

# 强制更新（忽略今天已运行的记录）
.\update-openclaw.ps1 -Force

# 仅生成报告（不更新）
.\update-openclaw.ps1 -ReportOnly
```

### 查看更新报告

报告保存在：`D:\AI编程\openclaw\openclaw-report.txt`

---

## 安全检查清单

| 检查项 | 状态 | 操作 |
|--------|------|------|
| 升级到最新版本 | ⬜ | `npm update -g openclaw` |
| Gateway绑定本地 | ⬜ | `gateway.bind loopback` |
| 限制文件访问范围 | ⬜ | 设置专用workspace |
| 加固配置文件权限 | ⬜ | `icacls` 命令 |
| 启用token认证 | ⬜ | 默认已启用 |
| 定期安全审计 | ⬜ | 运行 `openclaw doctor` |

---

## 常见安全错误

### 错误：Gateway暴露到公网

**症状**：`gateway.bind` 设置为 `0.0.0.0`

**风险**：任何人都可以访问您的OpenClaw实例

**解决方案**：
```powershell
.\openclaw.bat config set -- gateway.bind loopback
```

### 错误：配置文件权限过宽

**症状**：其他用户可以读取配置文件

**风险**：API密钥泄露

**解决方案**：
```powershell
icacls "C:\Users\z\.openclaw\openclaw.json" /inheritance:r /grant:r "$env:USERNAME:F"
```
