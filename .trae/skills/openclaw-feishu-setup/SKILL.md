---
name: "openclaw-feishu-setup"
description: "Configures OpenClaw with Feishu bot integration using SiliconFlow DeepSeek model. Invoke when user wants to set up OpenClaw Feishu bot or configure AI assistant for Feishu."
---

# OpenClaw Feishu Bot Setup Guide

Complete tutorial for configuring OpenClaw AI assistant with Feishu messaging platform using SiliconFlow DeepSeek model.

---

## Prerequisites

- Node.js >= 22 installed
- OpenClaw installed globally: `npm i -g openclaw`
- SiliconFlow API key (from https://cloud.siliconflow.cn)
- Feishu developer account (https://open.feishu.cn)

---

## Step 1: Install OpenClaw and Dependencies

### 1.1 Install OpenClaw
```bash
npm i -g openclaw
```

### 1.2 Run Onboarding
```bash
openclaw onboard --install-daemon
```

### 1.3 Install Feishu SDK (CRITICAL!)
```bash
npm install -g @larksuiteoapi/node-sdk
```

### 1.4 Create SDK Junction Link (Windows ONLY!)

**PITFALL:** Without this, you will get error: `Cannot find module '@larksuiteoapi/node-sdk'`

```powershell
# Find OpenClaw installation path
$openclawPath = (Get-Command openclaw).Source | Split-Path | Split-Path

# Create junction link
$sdkSource = "$env:APPDATA\npm\node_modules\@larksuiteoapi"
$sdkTarget = "$openclawPath\node_modules\@larksuiteoapi"

New-Item -ItemType Junction -Path $sdkTarget -Target $sdkSource -Force
```

---

## Step 2: Create Feishu Application

### 2.1 Create App
1. Visit https://open.feishu.cn/app
2. Click "Create Enterprise Self-built App"
3. Fill in app name (e.g., "OpenClaw Assistant")
4. After creation, note down:
   - **App ID** (starts with `cli_`)
   - **App Secret**

### 2.2 Add Permissions (CRITICAL!)

**PITFALL:** Missing permissions will cause `HTTP 403: forbidden` error

**Required Permissions:**
```
im:message                      - Send and receive messages
im:message:send_as_bot          - Send messages as bot
im:message:receive_as_bot       - Receive @mentions in groups
im:chat                         - Get group info
im:chat:readonly                - Get group info (readonly)
im:chat.member:readonly         - Get group members
contact:contact.base:readonly   - Get basic contact info (CRITICAL!)
contact:user.base:readonly      - Get user basic info
contact:user.employee_id:readonly - Get user employee ID
im:resource                     - Upload and get files/images
```

**JSON Import Method (Recommended):**
```json
{
  "scopes": {
    "tenant": [
      "im:message",
      "im:message:send_as_bot",
      "im:message:receive_as_bot",
      "im:chat",
      "im:chat:readonly",
      "im:chat.member:readonly",
      "contact:contact.base:readonly",
      "contact:user.base:readonly",
      "contact:user.employee_id:readonly",
      "im:resource"
    ]
  }
}
```

**Steps:**
1. Go to "Permission Management"
2. Search each permission
3. Click "Add Permission"
4. Confirm

### 2.3 Configure Event Subscription (CRITICAL!)

**PITFALL:** Wrong subscription mode = bot won't receive messages!

**Correct Configuration:**
1. Go to "Events & Callbacks"
2. **Subscription Mode**: Select **"Use Long Connection to Receive Events"**
   - **NOT** "Send events to developer server"!
3. Add event: `im.message.receive_v1`
4. Click "Save"

### 2.4 Enable Bot Feature
1. Go to "App Features" -> "Bot"
2. Enable bot functionality
3. Set bot name and avatar

### 2.5 Publish Application
1. Go to "Version Management & Release"
2. Create new version
3. Apply for release

**PITFALL:** Every permission change requires a new version publication!

---

## Step 3: Configure OpenClaw

### 3.1 Configure Feishu Channel
```bash
openclaw config set -- channels.feishu.appId "YOUR_APP_ID"
openclaw config set -- channels.feishu.appSecret "YOUR_APP_SECRET"
```

### 3.2 Configure SiliconFlow Model (One Command)

**PITFALL:** Don't use individual `config set` commands for model - use `onboard`!

```bash
openclaw onboard --non-interactive --auth-choice custom-api-key --custom-base-url "https://api.siliconflow.cn/v1" --custom-model-id "deepseek-ai/DeepSeek-V3" --custom-api-key "YOUR_SILICONFLOW_API_KEY" --custom-compatibility openai --accept-risk
```

### 3.3 Set Context Window (CRITICAL!)

**PITFALL:** Default context window causes `Model context window too small` error

```bash
openclaw config set -- models.providers.custom-api-siliconflow-cn.models.0.contextWindow 128000
```

### 3.4 Configure Workspace
```bash
openclaw config set -- agents.defaults.workspace "YOUR_WORKSPACE_PATH"
```

### 3.5 Enable Token Optimization (Optional)
```bash
openclaw config set -- agents.defaults.contextPruning.mode "cache-ttl"
openclaw config set -- agents.defaults.contextPruning.ttl "1h"
openclaw config set -- agents.defaults.compaction.mode "safeguard"
openclaw config set -- hooks.internal.entries.session-memory.enabled true
```

---

## Step 4: Start Gateway

```bash
openclaw gateway
```

**Verify Success:**
```
[gateway] listening on ws://127.0.0.1:18789
[feishu] feishu[main]: WebSocket client started
[info]: [ '[ws]', 'ws client ready' ]
```

---

## Step 5: Test Bot

### Group Chat Test
1. Add bot to group
2. Send: `@BotName 你好`
3. Bot should respond

**PITFALL:** Must @mention bot in group chats!

### Direct Message Test
1. Search bot name in Feishu
2. Send message
3. Bot should respond

---

# Complete Pitfall Reference

## Pitfall 1: Feishu Plugin Failed to Load

**Error:**
```
[plugins] feishu failed to load: Error: Cannot find module '@larksuiteoapi/node-sdk'
```

**Root Cause:** SDK not installed or not linked

**Solution:**
```bash
npm install -g @larksuiteoapi/node-sdk

# Create junction link
$openclawPath = (Get-Command openclaw).Source | Split-Path | Split-Path
New-Item -ItemType Junction -Path "$openclawPath\node_modules\@larksuiteoapi" -Target "$env:APPDATA\npm\node_modules\@larksuiteoapi" -Force
```

---

## Pitfall 2: Access Denied (99991672)

**Error:**
```
HTTP 403: forbidden: Request not allowed
code: 99991672 - Access denied. scopes required: [contact:contact.base:readonly]
```

**Root Cause:** Missing `contact:contact.base:readonly` permission

**Solution:**
1. Add permission in Feishu Open Platform
2. Create and publish new version
3. Wait 5 minutes
4. Restart gateway

---

## Pitfall 3: Unknown Model

**Error:**
```
Agent failed before reply: Unknown model: siliconflow/deepseek-ai/DeepSeek-V3
```

**Root Cause:** Model provider not configured

**Solution:**
```bash
openclaw onboard --non-interactive --auth-choice custom-api-key --custom-base-url "https://api.siliconflow.cn/v1" --custom-model-id "deepseek-ai/DeepSeek-V3" --custom-api-key "YOUR_API_KEY" --custom-compatibility openai --accept-risk
```

---

## Pitfall 4: Context Window Too Small

**Error:**
```
Agent failed before reply: Model context window too small (4096 tokens). Minimum is 16000.
```

**Root Cause:** Default context window insufficient

**Solution:**
```bash
openclaw config set -- models.providers.custom-api-siliconflow-cn.models.0.contextWindow 128000
```

---

## Pitfall 5: Bot Not Receiving Messages

**Symptoms:** Bot online but doesn't respond

**Root Causes:**
1. Wrong subscription mode (must be "Long Connection")
2. Event not added (`im.message.receive_v1`)
3. Changes not published
4. Waiting for propagation (5-10 min)

**Solution:**
1. Check subscription mode = "Use Long Connection"
2. Check event `im.message.receive_v1` added
3. Publish new version
4. Wait 5-10 minutes

---

## Pitfall 6: HTTP 403 Forbidden

**Error:** `HTTP 403: forbidden: Request not allowed`

**Root Causes:**
1. Missing permissions
2. Permissions not published
3. Not using @mention in group chat

**Solution:**
1. Add all required permissions
2. Publish new version
3. Use @mention in group chats

---

## Pitfall 7: Config Validation Failed

**Error:**
```
Error: Config validation failed: models.providers.siliconflow.baseUrl
```

**Root Cause:** Using `config set` for model configuration

**Solution:** Use `onboard` command instead of individual `config set`

---

## Pitfall 8: Gateway Token Mismatch

**Error:**
```
gateway closed (1008): unauthorized: device token mismatch
```

**Solution:** Restart gateway - auto-repairs on restart

---

## Pitfall 9: Wrong Subscription Mode

**PITFALL:** Selecting "Send events to developer server" instead of "Use Long Connection"

**Result:** Bot will NOT receive any messages!

**Solution:** Always select "Use Long Connection to Receive Events"

---

## Pitfall 10: Group Chat Without @mention

**PITFALL:** Sending message in group without @mentioning bot

**Result:** Bot will NOT respond

**Solution:** Always @mention bot in group chats: `@BotName your message`

---

# Quick Reference

## Essential Commands

| Command | Description |
|---------|-------------|
| `openclaw gateway` | Start gateway |
| `openclaw logs` | View logs |
| `openclaw doctor` | Check config |
| `openclaw doctor --fix` | Auto-fix issues |
| `openclaw config get` | View config |

## Key Points

1. **Long Connection Mode** - MUST select for event subscription
2. **All Permissions** - Add ALL required permissions
3. **SDK Junction Link** - Required on Windows
4. **Context Window** - Set to 128000
5. **Publish Version** - Required after permission changes
6. **Wait Time** - 5-10 minutes after publishing
7. **@mention** - Required in group chats
8. **Use onboard** - For model configuration
9. **Restart Gateway** - After any config change
10. **Check Logs** - Always check logs for errors

## Deployment Checklist

- [ ] Node.js >= 22 installed
- [ ] OpenClaw installed globally
- [ ] Feishu SDK installed globally
- [ ] SDK junction link created
- [ ] Feishu app created
- [ ] All permissions added
- [ ] Event subscription configured (Long Connection)
- [ ] im.message.receive_v1 added
- [ ] Bot feature enabled
- [ ] App version published
- [ ] Feishu channel configured
- [ ] SiliconFlow model configured (via onboard)
- [ ] Context window set to 128000
- [ ] Gateway started successfully
- [ ] Bot tested in Feishu
