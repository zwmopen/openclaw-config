const axios = require('axios');

/**
 * 测试 codex-gateway 是否正常工作
 * 该脚本会向 codex-gateway 发送一个简单的请求，验证它是否能正常响应
 */
async function testCodexGateway() {
  try {
    console.log('测试 codex-gateway 连接...');
    
    // 测试 codex-gateway 是否运行
    const healthCheck = await axios.get('http://127.0.0.1:8319/v1/models', {
      headers: {
        'Authorization': 'Bearer sk-test'
      }
    });
    
    console.log('✓ codex-gateway 健康检查成功');
    console.log('可用模型:', healthCheck.data.data.map(m => m.id));
    
    // 测试 OpenClaw 配置
    console.log('\n测试 OpenClaw 配置...');
    const response = await axios.post('http://127.0.0.1:18789/v1/chat/completions', {
      model: 'codex-gateway/gpt-5.3-codex',
      messages: [
        {
          role: 'system',
          content: '你是一个智能助手'
        },
        {
          role: 'user',
          content: 'Hello, 测试 codex-gateway 连接'
        }
      ],
      max_tokens: 100
    }, {
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer 2d65353ea3422e1bd863c865f7cc9b3d92514be0fd19ebd8'
      }
    });
    
    console.log('✓ OpenClaw 配置测试成功');
    console.log('模型响应:', response.data.choices[0].message.content);
    
  } catch (error) {
    console.error('测试失败:', error.message);
    if (error.response) {
      console.error('响应状态:', error.response.status);
      console.error('响应数据:', error.response.data);
    }
  }
}

testCodexGateway();