const https = require('https');

// 测试智谱GLM-4模型
function testZhipuGLM4() {
    return new Promise((resolve, reject) => {
        const apiKey = 'aaba2e5167954bac8fb2188d882c40db.qP2yJKa6qjLA16XA';
        const data = JSON.stringify({
            model: 'glm-4',
            messages: [
                { role: 'user', content: '你好，请简单回复' }
            ],
            max_tokens: 100
        });

        const options = {
            hostname: 'open.bigmodel.cn',
            port: 443,
            path: '/api/paas/v4/chat/completions',
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${apiKey}`,
                'Content-Length': data.length
            }
        };

        console.log('=== 智谱GLM-4模型测试 ===\n');
        const startTime = Date.now();

        const req = https.request(options, (res) => {
            let body = '';
            res.on('data', (chunk) => { body += chunk; });
            res.on('end', () => {
                const elapsed = Date.now() - startTime;
                try {
                    const result = JSON.parse(body);
                    console.log('响应时间:', elapsed, 'ms');
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

// 测试硅基流动DeepSeek-V3模型
function testSiliconFlowDeepSeek() {
    return new Promise((resolve, reject) => {
        const apiKey = 'sk-ebvafedwpkqmhxgmpnqbsmmktgngdxbxrlhgevkxqqrwghnk';
        const data = JSON.stringify({
            model: 'deepseek-ai/DeepSeek-V3',
            messages: [
                { role: 'user', content: '你好，请简单回复' }
            ],
            max_tokens: 100
        });

        const options = {
            hostname: 'api.siliconflow.cn',
            port: 443,
            path: '/v1/chat/completions',
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${apiKey}`,
                'Content-Length': data.length
            }
        };

        console.log('\n=== 硅基流动DeepSeek-V3模型测试 ===\n');
        const startTime = Date.now();

        const req = https.request(options, (res) => {
            let body = '';
            res.on('data', (chunk) => { body += chunk; });
            res.on('end', () => {
                const elapsed = Date.now() - startTime;
                try {
                    const result = JSON.parse(body);
                    console.log('响应时间:', elapsed, 'ms');
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

async function testAll() {
    await testZhipuGLM4().catch(() => {});
    await testSiliconFlowDeepSeek().catch(() => {});
}

testAll();
