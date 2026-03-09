const https = require('https');

const baseUrl = 'https://dashscope.aliyuncs.com';
const apiKey = 'sk-30c2f54620b2492993ca838323748d71';

// 测试阿里云百炼通义千问模型
function testModel() {
    return new Promise((resolve, reject) => {
        const data = JSON.stringify({
            model: 'qwen-plus',
            messages: [
                { role: 'user', content: '你好，请简单回复' }
            ],
            max_tokens: 100
        });

        const options = {
            hostname: 'dashscope.aliyuncs.com',
            port: 443,
            path: '/compatible-mode/v1/chat/completions',
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${apiKey}`,
                'Content-Length': data.length
            }
        };

        console.log('=== 阿里云百炼通义千问模型测试 ===\n');
        console.log('请求URL:', `https://${options.hostname}${options.path}`);
        console.log('请求模型: qwen-plus');
        console.log('');
        console.log('API Key:', apiKey);
        console.log('');


        const startTime = Date.now();

        const req = https.request(options, (res) => {
            let body = '';
            res.on('data', (chunk) => { body += chunk; });
            res.on('end', () => {
                const elapsed = Date.now() - startTime;
                try {
                    const result = JSON.parse(body);
                    console.log('响应时间:', elapsed, 'ms');
                    console.log('');
                    
                    if (result.choices && result.choices[0]) {
                        console.log('✅ 模型响应成功');
                        console.log('回复内容:', result.choices[0].message.content);
                    } else {
                        console.log('❌ 模型响应失败');
                        console.log('错误信息:', JSON.stringify(result, null, 2));
                    }
                    resolve(result);
                } catch (e) {
                    console.log('❌ 解析响应失败');
                    console.log('原始响应:', body);
                    reject(e);
                }
            });
        });

        req.on('error', (error) => {
            console.log('❌ 请求失败:', error.message);
            reject(error);
        });

        req.setTimeout(30000, () => {
            console.log('❌ 请求超时（30秒）');
            req.destroy();
            reject(new Error('Timeout'));
        });

        req.write(data);
        req.end();
    });
}

testModel().catch(() => {});
