# OpenClaw 配置备份文档

**备份时间**: 2026-03-01 23:20
**版本**: OpenClaw 2026.2.21-2
**工作目录**: `D:\AI编程\openclaw\`

---

## 一、模型提供商配置

### 1. 联通元景 (Unicom) - GLM-5 ⭐ 主模型

| 配置项 | 值 |
|--------|-----|
| 提供商ID | `unicom` |
| Base URL | `https://maas-api.ai-yuanjing.com/openapi/compatible-mode/v1` |
| API Key | `sk-33b2451706fb4098850b14a9dfbb5827` |
| 模型ID | `glm-5` |
| 上下文窗口 | 128,000 tokens |
| 状态 | **默认模型** (大哥的会员) |
| 用量查询 | https://maas.ai-yuanjing.com/aibase/userCenter/realTime |

---

### 2. 智谱 Anthropic API - GLM-4.6/4.7/4.5 🆕

| 配置项 | 值 |
|--------|-----|
| 提供商ID | `zhipu-anthropic` |
| Base URL | `https://open.bigmodel.cn/api/anthropic` |
| API Key | `a9020da3e8ee452a9be4205797e84e33.lkAMTD1wfTMt4SFH` |
| 可用模型 | GLM-4.6, GLM-4.7, GLM-4.5, GLM-4.5-Air |
| 状态 | 备用 |

---

### 3. 智谱官网 (Zhipu Official) - GLM-4-Flash

| 配置项 | 值 |
|--------|-----|
| 提供商ID | `zhipu-official` |
| Base URL | `https://open.bigmodel.cn/api/paas/v4/` |
| API Key | `aaba2e5167954bac8fb2188d882c40db.qP2yJKa6qjLA16XA` |
| 模型ID | `glm-4-flash` |
| 状态 | 备用 |

---

### 4. 硅基流动 (SiliconFlow) - DeepSeek-V3

| 配置项 | 值 |
|--------|-----|
| 提供商ID | `custom-api-siliconflow-cn` |
| Base URL | `https://api.siliconflow.cn/v1` |
| API Key | `sk-hyaakxkupozeqeisekcvnvterzifvgcjconbghtmxgrjufke` |
| 模型ID | `deepseek-ai/DeepSeek-V3` |
| 状态 | 备用 |

---

## 二、Token 优化配置

已启用以下优化（预计节省 40% token）：

| 配置项 | 值 |
|--------|-----|
| 上下文修剪 | `cache-ttl` |
| TTL | 1小时 |
| 保留最近助手消息 | 3条 |
| 软修剪比例 | 30% |
| 硬清除比例 | 50% |
| 压缩模式 | `safeguard` |
| 保留Token | 16,384 |
| 保留最近Token | 20,000 |
| 心跳间隔 | 55分钟 |

---

## 三、飞书通道配置

| 配置项 | 值 |
|--------|-----|
| App ID | `cli_a92b975b47781bca` |
| App Secret | `E6prhpRy7rsrVa7lMwpnHeNwbmsxkTCs` |
| Bot名称 | `OpenClaw助手` |
| DM Policy | `open` |
| 权限 | 仅消息相关（无云空间权限） |

---

## 四、网关配置

| 配置项 | 值 |
|--------|-----|
| 端口 | `18789` |
| 绑定模式 | `loopback` (仅本地) |
| 认证Token | `2d65353ea3422e1bd863c865f7cc9b3d92514be0fd19ebd8` |

---

## 五、文件结构

```
D:\AI编程\openclaw\
├── .openclaw\              # 系统数据
│   ├── agents\             # 会话历史
│   ├── cron\               # 定时任务
│   ├── devices\            # 设备配对
│   ├── identity\           # 身份信息
│   ├── media\              # 收到的图片
│   └── openclaw.json       # 主配置
├── backup\                 # 旧配置备份
├── memory\                 # 日记记忆
│   └── 2026-03-01.md
├── AGENTS.md               # 行为准则
├── SOUL.md                 # 灵魂/性格
├── IDENTITY.md             # 我是谁
├── USER.md                 # 大哥信息
├── MEMORY.md               # 长期记忆
├── TOOLS.md                # 工具笔记
├── HEARTBEAT.md            # 定时检查
└── *.ps1/*.bat             # 脚本文件
```

---

## 六、切换模型命令

```bash
# 切换到 GLM-5 (联通元景)
openclaw config set agents.defaults.model.primary "unicom/glm-5"

# 切换到 GLM-4.6 (智谱 Anthropic)
openclaw config set agents.defaults.model.primary "zhipu-anthropic/glm-4.6"

# 切换到 DeepSeek-V3 (硅基流动)
openclaw config set agents.defaults.model.primary "custom-api-siliconflow-cn/deepseek-ai/DeepSeek-V3"

# 切换到 GLM-4-Flash (智谱官网)
openclaw config set agents.defaults.model.primary "zhipu-official/glm-4-flash"
```

---

## 七、待改进

- [ ] 配置图像识别模型
- [ ] 配置 Brave API key (搜索功能)
- [ ] 连接浏览器扩展
- [ ] 研究向量数据库长期记忆

---

**文档维护**: 配置变更后及时更新此文档。
