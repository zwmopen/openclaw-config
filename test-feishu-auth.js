const https = require('https');

const appId = 'cli_a92b975b47781bca';
const appSecret = 'E6prhpRy7rsrVa7lMwpnHeNwbmsxkTCs';

// 获取tenant_access_token
function getAccessToken() {
    return new Promise((resolve, reject) => {
        const data = JSON.stringify({
            app_id: appId,
            app_secret: appSecret
        });

        const options = {
            hostname: 'open.feishu.cn',
            port: 443,
            path: '/open-apis/auth/v3/tenant_access_token/internal',
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Content-Length': data.length
            }
        };

        const req = https.request(options, (res) => {
            let body = '';
            res.on('data', (chunk) => { body += chunk; });
            res.on('end', () => {
                try {
                    const result = JSON.parse(body);
                    resolve(result);
                } catch (e) {
                    reject(e);
                }
            });
        });

        req.on('error', reject);
        req.write(data);
        req.end();
    });
}

// 测试
async function test() {
    console.log('=== 飞书权限测试 ===\n');
    
    try {
        const result = await getAccessToken();
        console.log('Token获取结果:', JSON.stringify(result, null, 2));
        
        if (result.tenant_access_token) {
            console.log('\n✅ 成功获取访问令牌');
            console.log('令牌有效期:', result.expire, '秒');
        } else {
            console.log('\n❌ 获取访问令牌失败');
            console.log('错误代码:', result.code);
            console.log('错误信息:', result.msg);
        }
    } catch (error) {
        console.log('\n❌ 请求失败:', error.message);
    }
}

test();
