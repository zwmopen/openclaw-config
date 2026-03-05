# OpenClaw 文档中心

> 本文档整合了OpenClaw的所有配置、使用和部署信息。

---

## 📋 目录

1. [快速开始](#快速开始)
2. [配置说明](#配置说明)
3. [模型配置](#模型配置)
4. [飞书集成](#飞书集成)
5. [云服务器](#云服务器)
6. [常见问题](#常见问题)

---

## 快速开始

### 启动方式

**方式一：桌面快捷方式**
- 双击桌面上的 `OpenClaw.lnk` 启动

**方式二：命令行启动**
```powershell
cd D:\AI编程\openclaw
.\start-all.ps1
```

**方式三：分别启动**
```powershell
# 启动网关
.\start-gateway.ps1

# 启动前端面板
powershell -ExecutionPolicy Bypass -File "panel\openclaw-panel-server.ps1"
```

### 访问地址

| 服务 | 地址 |
|------|------|
| 前端面板 | http://localhost:38789 |
| 网关 | http://127.0.0.1:18789 |

---

## 配置说明

### 配置文件位置

```
D:\AI编程\openclaw\.openclaw\openclaw.json
```

### 环境变量

| 变量 | 值 |
|------|-----|
| OPENCLAW_STATE_DIR | D:\AI编程\openclaw\.openclaw |
| OPENCLAW_CONFIG_PATH | D:\AI编程\openclaw\.openclaw\openclaw.json |

---

## 模型配置

### 当前配置的模型

| 提供商 | 模型 | 状态 | 说明 |
|--------|------|------|------|
| 联通元景 | GLM-5 | 🟢 当前使用 | 主力模型 |
| 硅基流动 | DeepSeek-V3 | 🟡 备用 | 高性价比 |
| 智谱AI | GLM-4-Flash | 🟡 备用 | 免费额度 |

### 切换模型

```bash
# 切换到联通元景GLM-5
openclaw config set -- agents.defaults.model.primary "unicom/glm-5"

# 切换到硅基流动DeepSeek
openclaw config set -- agents.defaults.model.primary "custom-api-siliconflow-cn/deepseek-ai/DeepSeek-V3"

# 切换到智谱GLM-4-Flash
openclaw config set -- agents.defaults.model.primary "zhipu-official/glm-4-flash"
```

---

## 飞书集成

### 飞书应用配置

| 配置项 | 值 |
|--------|-----|
| App ID | cli_a92b975b47781bca |
| App Secret | E6prhpRy7rsrVa7lMwpnHeNwbmsxkTCs |
| 机器人名称 | OpenClaw助手 |

### 必需权限

```
im:message                      - 获取与发送单聊、群组消息
im:message:send_as_bot          - 以应用身份发消息
im:message:receive_as_bot       - 接收群聊中@机器人消息
im:chat                         - 获取群组信息
contact:contact.base:readonly   - 获取通讯录基本信息
```

### 事件订阅

- 订阅方式：**使用长连接接收事件**
- 事件：`im.message.receive_v1`

---

## 云服务器

### 服务器信息

| 配置项 | 值 |
|--------|-----|
| 公网IP | 116.176.77.165 |
| SSH端口 | 22 |
| 用户名 | root |
| 密码 | 147258AA@s |
| VNC密码 | 147258AA |
| 到期时间 | 2026-04-01 |

### 连接方式

```bash
ssh root@116.176.77.165
```

### 部署命令

```powershell
.\scripts\deploy-to-cloud.ps1
```

---

## 常见问题

### 1. 飞书机器人不回复

**检查项：**
1. 事件订阅是否为"长连接模式"
2. 权限是否已发布
3. `allowFrom: ["*"]` 是否配置

### 2. 模型切换不生效

**解决方案：**
1. 重启网关
2. 检查配置文件中的 `agents.defaults.model.primary`

### 3. 前端面板黑屏

**解决方案：**
1. 清除浏览器缓存
2. 使用无痕模式
3. 检查服务器是否运行

---

## 相关文档

- [OpenClaw飞书机器人自动化部署指南](./OpenClaw飞书机器人自动化部署指南.md)
- [Token优化配置指南](./Token优化配置指南.md)
- [联通云服务器使用指南](./联通云服务器使用指南.md)

---

## 技能资源

- [Awesome OpenClaw Skills](https://github.com/VoltAgent/awesome-openclaw-skills) - 5494+ 技能仓库
- [OpenClaw 官方文档](https://github.com/openclaw/openclaw)

---

*最后更新: 2026-03-01*
