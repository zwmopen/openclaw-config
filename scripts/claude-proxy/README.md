# Claude Code代理服务器

## 功能

转换Claude Code的Anthropic API格式到联通元景的OpenAI格式。

## 端口

15721

## 使用方法

### 方式1：前台运行（测试）

```powershell
cd D:\AI编程\openclaw\scripts\claude-proxy
.\start.ps1
```

### 方式2：安装为Windows服务（推荐）

```powershell
cd D:\AI编程\openclaw\scripts\claude-proxy
.\install-service.ps1
```

### 方式3：后台运行

```powershell
Start-Process node -ArgumentList "D:\AI编程\openclaw\scripts\claude-proxy\server.js" -WindowStyle Hidden
```

## CC Switch配置

文件：`C:\Users\z\.cc-switch\profiles\unicom-new\settings.json`

```json
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "PROXY_MANAGED",
    "ANTHROPIC_BASE_URL": "http://127.0.0.1:15721"
  }
}
```

## 启动顺序

1. OpenClaw启动（端口18789）
2. Claude代理服务器启动（端口15721）
3. CC Switch切换配置（unicom-new）
4. Claude Code启动

## 测试

```powershell
# 测试代理服务器是否运行
Test-NetConnection -ComputerName 127.0.0.1 -Port 15721

# 测试Claude Code
echo "Hello" | claude
```

## 日志

代理服务器会输出详细的请求/响应日志，方便调试。
