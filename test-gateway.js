const http = require('http');

/**
 * 测试 OpenClaw 网关
 * 该脚本会向 OpenClaw 网关发送一个简单的请求，验证它是否能正常响应
 */
function testOpenClawGateway() {
  console.log('测试 OpenClaw 网关...');
  
  // 测试网关健康检查
  const options = {
    hostname: '127.0.0.1',
    port: 18789,
    path: '/__openclaw__/canvas/',
    method: 'GET'
  };
  
  const req = http.request(options, (res) => {
    console.log(`状态码: ${res.statusCode}`);
    console.log(`响应头: ${JSON.stringify(res.headers)}`);
    
    res.on('data', (d) => {
      process.stdout.write(d.slice(0, 500) + '...'); // 只显示前500个字符
    });
    
    res.on('end', () => {
      console.log('\n测试完成');
    });
  });
  
  req.on('error', (e) => {
    console.error(`请求错误: ${e.message}`);
  });
  
  req.end();
}

testOpenClawGateway();