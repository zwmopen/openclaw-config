# OpenClaw 飞书集成诊断脚本
# 检查所有可能导致飞书消息不回复的问题

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  OpenClaw 飞书集成诊断" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "检查项目：" -ForegroundColor Yellow

# 1. 检查Node.js版本
Write-Host ""
Write-Host "[1/8] 检查Node.js版本..." -ForegroundColor White
$nodeVersion = node --version
if ($nodeVersion -ge "v20.0.0") {
    Write-Host "  ✅ Node.js版本: $nodeVersion" -ForegroundColor Green
} else {
    Write-Host "  ❌ Node.js版本过低: $nodeVersion (需要 >= v20.0.0)" -ForegroundColor Red
}

# 2. 检查飞书SDK
Write-Host ""
Write-Host "[2/8] 检查飞书SDK..." -ForegroundColor White
$sdkPath = "$env:APPDATA\npm\node_modules\@larksuiteoapi"
if (Test-Path $sdkPath) {
    Write-Host "  ✅ 飞书SDK已安装: $sdkPath" -ForegroundColor Green
} else {
    Write-Host "  ❌ 飞书SDK未安装" -ForegroundColor Red
    Write-Host "  解决: npm install -g @larksuiteoapi/node-sdk" -ForegroundColor Yellow
}

# 3. 检查junction link
Write-Host ""
Write-Host "[3/8] 检查Junction Link..." -ForegroundColor White
$junctionPath = "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node_modules\@larksuiteoapi"
if (Test-Path $junctionPath) {
    Write-Host "  ✅ Junction Link已创建: $junctionPath" -ForegroundColor Green
} else {
    Write-Host "  ❌ Junction Link未创建" -ForegroundColor Red
    Write-Host "  解决: 运行创建junction link的命令" -ForegroundColor Yellow
}

# 4. 检查OpenClaw网关
Write-Host ""
Write-Host "[4/8] 检查OpenClaw网关..." -ForegroundColor White
$gatewayProcess = Get-Process -Name "node" -ErrorAction SilentlyContinue | 
    Where-Object { $_.CommandLine -like "*openclaw*gateway*" }
if ($gatewayProcess) {
    Write-Host "  ✅ OpenClaw网关运行中 (PID: $($gatewayProcess.Id))" -ForegroundColor Green
} else {
    Write-Host "  ❌ OpenClaw网关未运行" -ForegroundColor Red
    Write-Host "  解决: 运行 start-gateway.ps1" -ForegroundColor Yellow
}

# 5. 检查端口
Write-Host ""
Write-Host "[5/8] 检查端口18789..." -ForegroundColor White
$port = netstat -ano | findstr ":18789"
if ($port) {
    Write-Host "  ✅ 端口18789已监听" -ForegroundColor Green
} else {
    Write-Host "  ❌ 端口18789未监听" -ForegroundColor Red
}

# 6. 检查配置文件
Write-Host ""
Write-Host "[6/8] 检查配置文件..." -ForegroundColor White
$configPath = "D:\AI编程\openclaw\.openclaw\openclaw.json"
if (Test-Path $configPath) {
    Write-Host "  ✅ 配置文件存在" -ForegroundColor Green
    $config = Get-Content $configPath | ConvertFrom-Json
    
    # 检查飞书配置
    if ($config.channels.feishu.enabled) {
        Write-Host "  ✅ 飞书通道已启用" -ForegroundColor Green
    } else {
        Write-Host "  ❌ 飞书通道未启用" -ForegroundColor Red
    }
    
    # 检查模型配置
    if ($config.agents.defaults.model.primary) {
        Write-Host "  ✅ 默认模型: $($config.agents.defaults.model.primary)" -ForegroundColor Green
    } else {
        Write-Host "  ❌ 未配置默认模型" -ForegroundColor Red
    }
} else {
    Write-Host "  ❌ 配置文件不存在" -ForegroundColor Red
}

# 7. 飞书应用配置检查清单
Write-Host ""
Write-Host "[7/8] 飞书应用配置检查清单：" -ForegroundColor White
Write-Host "  请手动检查以下项目：" -ForegroundColor Yellow
Write-Host "  □ 事件订阅模式: 必须选择'使用长连接接收事件'" -ForegroundColor White
Write-Host "  □ 事件类型: 必须添加 im.message.receive_v1" -ForegroundColor White
Write-Host "  □ 权限: 必须添加所有必需权限" -ForegroundColor White
Write-Host "  □ 版本发布: 每次权限变更后必须发布新版本" -ForegroundColor White
Write-Host "  □ 等待时间: 发布后需要等待5-10分钟" -ForegroundColor White

# 8. 必需权限列表
Write-Host ""
Write-Host "[8/8] 必需权限列表：" -ForegroundColor White
$permissions = @(
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
)

foreach ($perm in $permissions) {
    Write-Host "  • $perm" -ForegroundColor White
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  诊断完成" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "常见问题解决：" -ForegroundColor Yellow
Write-Host "1. 机器人不回复消息：" -ForegroundColor White
Write-Host "   - 检查事件订阅模式是否为'使用长连接'" -ForegroundColor White
Write-Host "   - 检查是否添加了im.message.receive_v1事件" -ForegroundColor White
Write-Host "   - 检查是否发布了新版本" -ForegroundColor White
Write-Host "   - 等待5-10分钟让配置生效" -ForegroundColor White

Write-Host ""
Write-Host "2. 权限错误（99991672）：" -ForegroundColor White
Write-Host "   - 添加缺失的权限" -ForegroundColor White
Write-Host "   - 发布新版本" -ForegroundColor White
Write-Host "   - 等待5-10分钟" -ForegroundColor White

Write-Host ""
Write-Host "3. 群聊不回复：" -ForegroundColor White
Write-Host "   - 必须使用@提及机器人" -ForegroundColor White
Write-Host "   - 格式: @OpenClaw助手 你的消息" -ForegroundColor White

Write-Host ""
Write-Host "飞书开放平台地址: https://open.feishu.cn/" -ForegroundColor Cyan
