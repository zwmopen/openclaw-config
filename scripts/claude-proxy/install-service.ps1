# Claude代理服务器安装脚本

Write-Host "正在安装Claude代理服务器..." -ForegroundColor Yellow

# 安装为Windows服务（使用node-windows）
npm install -g node-windows 2>$null

# 创建服务
$serviceScript = @'
const Service = require('node-windows').Service;

const svc = new Service({
  name: 'Claude Proxy Server',
  description: 'Claude Code代理服务器，转换Anthropic格式到OpenAI格式',
  script: 'D:\\AI编程\\openclaw\\scripts\\claude-proxy\\server.js',
  nodeOptions: []
});

svc.on('install', function() {
  svc.start();
  console.log('服务已安装并启动！');
});

svc.install();
'@

Set-Content -Path "install-service.js" -Value $serviceScript -Encoding UTF8

# 安装服务
node install-service.js

Write-Host "✅ Claude代理服务器已安装！" -ForegroundColor Green
Write-Host "端口: 15721" -ForegroundColor Cyan
Write-Host "目标API: https://maas-api.ai-yuanjing.com" -ForegroundColor Cyan
