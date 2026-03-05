const http = require('http');

const options = {
  hostname: 'localhost',
  port: 38789,
  path: '/api/ai/chat',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  }
};

const req = http.request(options, (res) => {
  let data = '';
  res.on('data', (chunk) => {
    data += chunk;
  });
  res.on('end', () => {
    console.log('AI Assistant Response:', data);
  });
});

req.on('error', (e) => {
  console.error('Error:', e);
});

req.write(JSON.stringify({ message: '你好，测试消息', model: 'deepseek' }));
req.end();
