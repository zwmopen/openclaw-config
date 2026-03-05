# OpenClaw通道配置总览

> 所有OpenClaw实例的通道配置汇总
> 最后更新：2026-03-05

---

## 📊 通道列表

| 通道 | 本地OpenClaw | 腾讯云OpenClaw | 说明 |
|------|-------------|---------------|------|
| **飞书** | ✅ OpenClaw助手 | ✅ 小龙虾（Trae） | 主通道 |
| **QQ机器人** | ❌ 未配置 | ✅ 已启用 | - |
| **钉钉** | ❌ 未配置 | ✅ 已启用 | - |
| **企业微信** | ❌ 未配置 | ✅ 已启用 | - |

---

## 1️⃣ 飞书配置

### 本地OpenClaw - OpenClaw助手 ✅

| 项目 | 值 |
|------|------|
| **Bot名称** | OpenClaw助手 |
| **App ID** | `cli_a92b975b47781bca` |
| **App Secret** | `E6prhpRy7rsrVa7lMwpnHeNwbmsxkTCs` |
| **管理后台** | https://open.feishu.cn/app/cli_a92b975b47781bca |
| **状态** | ✅ 已配置，运行中 |

### 腾讯云OpenClaw - 小龙虾（Trae） ✅

| 项目 | 值 |
|------|------|
| **Bot名称** | 腾讯小龙虾open claw |
| **App ID** | `cli_a9288d4a46b89bcb` |
| **App Secret** | `FjNdst92ILtErJUZOfo5dekJQX2Es3c3` |
| **管理后台** | https://open.feishu.cn/app/cli_a9288d4a46b89bcb/baseinfo |
| **应用状态** | ✅ 已启用，正式应用 |
| **发布状态** | 当前修改均已发布 |
| **配置状态** | ✅ 已配置完成 |
| **配对状态** | ✅ 已配对成功（2026-03-05） |

---

## 2️⃣ 配置JSON

### 本地OpenClaw飞书配置（已生效）

```json
{
  "feishu": {
    "enabled": true,
    "accounts": {
      "main": {
        "appId": "cli_a92b975b47781bca",
        "appSecret": "E6prhpRy7rsrVa7lMwpnHeNwbmsxkTCs",
        "botName": "OpenClaw助手"
      }
    },
    "dmPolicy": "open",
    "allowFrom": ["*"],
    "requireMention": false,
    "groupPolicy": "open",
    "groupAllowFrom": ["*"]
  }
}
```

### 腾讯云OpenClaw飞书配置（待配置）

```json
{
  "feishu": {
    "enabled": true,
    "accounts": {
      "main": {
        "appId": "cli_a9288d4a46b89bcb",
        "appSecret": "FjNdst92ILtErJUZOfo5dekJQX2Es3c3",
        "botName": "小龙虾"
      }
    },
    "dmPolicy": "open",
    "allowFrom": ["*"],
    "requireMention": false,
    "groupPolicy": "open",
    "groupAllowFrom": ["*"]
  }
}
```

---

## 3️⃣ 配置方法

### 腾讯云飞书配置步骤

1. **SSH登录**
   ```bash
   ssh -i C:\Users\z\.ssh\openclaw_key.pem root@111.231.58.240
   ```

2. **编辑配置**
   ```bash
   nano ~/.openclaw/openclaw.json
   ```

3. **找到plugins部分，添加飞书配置**
   
   在 `"plugins": { "entries": { ... } }` 中添加：
   ```json
   "feishu": {
     "enabled": true,
     "accounts": {
       "main": {
         "appId": "cli_a9288d4a46b89bcb",
         "appSecret": "FjNdst92ILtErJUZOfo5dekJQX2Es3c3",
         "botName": "小龙虾"
       }
     }
   }
   ```

4. **重启OpenClaw**
   ```bash
   pkill openclaw-gateway
   # OpenClaw会自动重启
   ```

---

## 4️⃣ QQ机器人配置（腾讯云）

| 项目 | 值 |
|------|------|
| **状态** | ✅ 已启用 |
| **版本** | 1.5.0 |
| **包名** | @sliverp/qqbot |

```json
{
  "qqbot": {
    "enabled": true
  }
}
```

---

## 5️⃣ 钉钉配置（腾讯云）

| 项目 | 值 |
|------|------|
| **状态** | ✅ 已启用 |
| **版本** | 1.3.2 |
| **包名** | @largezhou/ddingtalk |

```json
{
  "ddingtalk": {
    "enabled": true
  }
}
```

---

## 6️⃣ 企业微信配置（腾讯云）

| 项目 | 值 |
|------|------|
| **状态** | ✅ 已启用 |

```json
{
  "wecom": {
    "enabled": true
  }
}
```

---

## 📁 配置文件位置

### 本地OpenClaw
```
D:\AI编程\openclaw\.openclaw\openclaw.json
```

### 腾讯云OpenClaw
```
/root/.openclaw/openclaw.json
```

### SSH访问腾讯云
```bash
ssh -i C:\Users\z\.ssh\openclaw_key.pem root@111.231.58.240
```

---

## 📝 更新日志

- **2026-03-05**：更新飞书配置，区分本地和腾讯云两个Bot
- **2026-03-05**：创建通道配置总览文档
