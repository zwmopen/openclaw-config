const https = require('https');

function testModel(name, apiKey) {
    return new Promise((resolve) => {
        const data = JSON.stringify({
            model: 'glm-5',
            messages: [{ role: 'user', content: '你好' }],
            max_tokens: 50
        });

        const options = {
            hostname: 'maas-api.ai-yuanjing.com',
            port: 443,
            path: '/openapi/compatible-mode/v1/chat/completions',
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${apiKey}`,
                'Content-Length': Buffer.byteLength(data)
            }
        };

        console.log(`\n=== ${name} ===`);
        const start = Date.now();

        const req = https.request(options, (res) => {
            let body = '';
            res.on('data', (c) => body += c);
            res.on('end', () => {
                console.log('响应时间:', Date.now() - start, 'ms');
                try {
                    const r = JSON.parse(body);
                    if (r.choices) {
                        console.log('✅ 成功:', r.choices[0].message.content);
                    } else {
                        console.log('❌ 失败:', r.msg || r.error?.message || JSON.stringify(r));
                    }
                } catch (e) {
                    console.log('❌ 解析失败:', body.substring(0, 200));
                }
                resolve();
            });
        });

        req.on('error', (e) => { console.log('❌ 请求失败:', e.message); resolve(); });
        req.setTimeout(30000, () => { console.log('❌ 超时'); req.destroy(); resolve(); });
        req.write(data);
        req.end();
    });
}

(async () => {
    await testModel('联通元景GLM-5（当前配置）', 'sk-33b2451706fb4098850b14a9dfbb5827');
    await testModel('联通元景GLM-5（免费试用）', 'sk-sp-sflaCLbnEf06zqiIzGTKe1wrDEuFmIx0');
    await testModel('联通元景GLM-5（OpenClaw专用）', 'sk-KKahzJGjlNvc11PLMh8NHAbWY119Cspy');
})();
