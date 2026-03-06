# Claude Code代理服务器 v2
# 修复版本：正确处理联通元景API响应

const http = require('http');
const https = require('https');

const PORT = 15721;
const TARGET_API = 'maas-api.ai-yuanjing.com';
const API_KEY = 'sk-33b2451706fb4098850b14a9dfbb5827';

const server = http.createServer((req, res) => {
  const timestamp = new Date().toISOString();
  console.log(`\n[${timestamp}] ${req.method} ${req.url}`);

  // 设置CORS头
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, x-api-key, anthropic-version');

  // 处理OPTIONS请求
  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }

  // 只处理/v1/messages请求
  if (req.url.startsWith('/v1/messages')) {
    let body = '';
    req.on('data', chunk => {
      body += chunk.toString();
    });

    req.on('end', () => {
      try {
        // 解析Anthropic格式请求
        const anthropicReq = JSON.parse(body);
        console.log('\n=== Anthropic Request ===');
        console.log(JSON.stringify(anthropicReq, null, 2));

        // 转换为OpenAI格式
        const openaiReq = {
          model: 'glm-5',  // 强制使用glm-5
          messages: anthropicReq.messages || [],
          stream: false,
          max_tokens: anthropicReq.max_tokens || 4096,
          temperature: anthropicReq.temperature || 0.7
        };

        // 处理system消息
        if (anthropicReq.system) {
          openaiReq.messages = [
            { role: 'system', content: anthropicReq.system },
            ...openaiReq.messages
          ];
        }

        console.log('\n=== OpenAI Request ===');
        console.log(JSON.stringify(openaiReq, null, 2));

        // 转发到联通元景API
        const options = {
          hostname: TARGET_API,
          port: 443,
          path: '/openapi/compatible-mode/v1/chat/completions',
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${API_KEY}`
          }
        };

        const proxyReq = https.request(options, (proxyRes) => {
          let responseBody = '';
          proxyRes.on('data', chunk => {
            responseBody += chunk.toString();
          });

          proxyRes.on('end', () => {
            try {
              console.log('\n=== Proxy Response Status ===');
              console.log(proxyRes.statusCode);
              
              const openaiRes = JSON.parse(responseBody);
              console.log('\n=== OpenAI Response ===');
              console.log(JSON.stringify(openaiRes, null, 2));

              // 提取content（优先使用content，如果没有则使用reasoning_content）
              const content = openaiRes.choices?.[0]?.message?.content || 
                             openaiRes.choices?.[0]?.message?.reasoning_content || 
                             '';

              // 转换为Anthropic格式响应
              const anthropicRes = {
                id: `msg_${Date.now()}`,
                type: 'message',
                role: 'assistant',
                model: openaiRes.model || 'glm-5',
                content: [{
                  type: 'text',
                  text: content
                }],
                stop_reason: openaiRes.choices?.[0]?.finish_reason || 'end_turn',
                usage: {
                  input_tokens: openaiRes.usage?.prompt_tokens || 0,
                  output_tokens: openaiRes.usage?.completion_tokens || 0
                }
              };

              console.log('\n=== Anthropic Response ===');
              console.log(JSON.stringify(anthropicRes, null, 2));

              res.writeHead(200, { 'Content-Type': 'application/json' });
              res.end(JSON.stringify(anthropicRes));
            } catch (error) {
              console.error('\n=== Response Parsing Error ===');
              console.error(error);
              res.writeHead(500, { 'Content-Type': 'application/json' });
              res.end(JSON.stringify({ error: 'Internal Server Error', details: error.message }));
            }
          });
        });

        proxyReq.on('error', (error) => {
          console.error('\n=== Proxy Request Error ===');
          console.error(error);
          res.writeHead(500, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ error: 'Proxy Error', details: error.message }));
        });

        proxyReq.write(JSON.stringify(openaiReq));
        proxyReq.end();

      } catch (error) {
        console.error('\n=== Request Parsing Error ===');
        console.error(error);
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Bad Request', details: error.message }));
      }
    });
  } else {
    // 其他请求返回404
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Not Found' }));
  }
});

server.listen(PORT, () => {
  console.log(`\n========================================`);
  console.log(`Claude Code Proxy Server Started!`);
  console.log(`Port: ${PORT}`);
  console.log(`Target API: https://${TARGET_API}`);
  console.log(`========================================\n`);
});
