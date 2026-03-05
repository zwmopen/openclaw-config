# 使用内网穿透实现飞书集成
# 本脚本将帮助你快速实现飞书消息接收

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  飞书集成 - 内网穿透解决方案" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "问题分析：" -ForegroundColor Yellow
Write-Host "  飞书机器人需要通过事件订阅接收消息" -ForegroundColor White
Write-Host "  事件订阅需要公网可访问的HTTPS地址" -ForegroundColor White
Write-Host "  本地环境（127.0.0.1）无法接收飞书推送" -ForegroundColor White

Write-Host ""
Write-Host "解决方案：" -ForegroundColor Yellow
Write-Host "  使用内网穿透工具，将本地端口映射到公网" -ForegroundColor White

Write-Host ""
Write-Host "方案1: 使用ngrok（推荐）" -ForegroundColor Green
Write-Host "  1. 访问 https://ngrok.com 注册账号" -ForegroundColor White
Write-Host "  2. 下载并安装ngrok" -ForegroundColor White
Write-Host "  3. 运行: ngrok http 18789" -ForegroundColor White
Write-Host "  4. 复制ngrok提供的HTTPS地址" -ForegroundColor White
Write-Host "  5. 在飞书开放平台配置事件订阅地址" -ForegroundColor White

Write-Host ""
Write-Host "方案2: 使用联通云服务器" -ForegroundColor Green
Write-Host "  1. SSH连接: ssh root@116.176.77.165" -ForegroundColor White
Write-Host "  2. 密码: 147258AA@s" -ForegroundColor White
Write-Host "  3. 运行部署脚本: ./deploy-to-unicom.ps1" -ForegroundColor White
Write-Host "  4. 公网地址: http://116.176.77.165:18789" -ForegroundColor White

Write-Host ""
Write-Host "方案3: 使用Cloudflare Tunnel（免费）" -ForegroundColor Green
Write-Host "  1. 访问 https://dash.cloudflare.com/" -ForegroundColor White
Write-Host "  2. 下载cloudflared工具" -ForegroundColor White
Write-Host "  3. 运行: cloudflared tunnel --url http://localhost:18789" -ForegroundColor White
Write-Host "  4. 复制提供的HTTPS地址" -ForegroundColor White

Write-Host ""
Write-Host "配置飞书事件订阅：" -ForegroundColor Yellow
Write-Host "  1. 登录飞书开放平台: https://open.feishu.cn/" -ForegroundColor White
Write-Host "  2. 进入你的应用 → 事件订阅" -ForegroundColor White
Write-Host "  3. 启用事件订阅" -ForegroundColor White
Write-Host "  4. 配置请求网址: https://你的域名/webhook/feishu" -ForegroundColor White
Write-Host "  5. 添加事件: im.message.receive_v1" -ForegroundColor White

Write-Host ""
Write-Host "注意事项：" -ForegroundColor Red
Write-Host "  - 内网穿透工具需要保持运行" -ForegroundColor White
Write-Host "  - 免费版ngrok有流量限制" -ForegroundColor White
Write-Host "  - 联通云服务器需要开放18789端口" -ForegroundColor White
Write-Host "  - 确保飞书应用权限已正确配置" -ForegroundColor White

Write-Host ""
Write-Host "当前系统状态：" -ForegroundColor Yellow
Write-Host "  OpenClaw网关: 运行中 (端口18789)" -ForegroundColor Green
Write-Host "  前端面板: 运行中 (端口38789)" -ForegroundColor Green
Write-Host "  飞书配置: 已配置App ID和Secret" -ForegroundColor Green
Write-Host "  事件订阅: ❌ 缺少公网回调地址" -ForegroundColor Red

Write-Host ""
Write-Host "下一步：" -ForegroundColor Cyan
Write-Host "  选择一个方案，配置公网访问地址" -ForegroundColor White
Write-Host "  然后在飞书开放平台配置事件订阅" -ForegroundColor White
Write-Host "  配置完成后，飞书消息就能正常接收和回复了" -ForegroundColor White
