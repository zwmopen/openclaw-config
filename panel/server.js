const http = require('http');
const fs = require('fs');
const path = require('path');

const port = 38789;
const scriptPath = __dirname;
const htmlFile = path.join(scriptPath, 'openclaw-panel-v2.html');
const baseDir = path.join(scriptPath, '..');
const configFile = path.join(baseDir, '.openclaw', 'openclaw.json');
const stateFile = path.join(scriptPath, '.panel-state.json');

function getConfig() {
    if (fs.existsSync(configFile)) {
        const content = fs.readFileSync(configFile, 'utf8');
        return JSON.parse(content);
    }
    return {};
}

function getState() {
    if (fs.existsSync(stateFile)) {
        const content = fs.readFileSync(stateFile, 'utf8');
        return JSON.parse(content);
    }
    return { startCount: 0, startTime: null, msgCount: 0, tokenUsed: 0 };
}

function saveState(state) {
    fs.writeFileSync(stateFile, JSON.stringify(state, null, 2), 'utf8');
}

function sendJson(response, data, status = 200) {
    response.writeHead(status, { 'Content-Type': 'application/json; charset=utf-8' });
    response.end(JSON.stringify(data));
}

function sendHtml(response, filePath) {
    if (fs.existsSync(filePath)) {
        const content = fs.readFileSync(filePath, 'utf8');
        response.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
        response.end(content);
    } else {
        response.writeHead(404);
        response.end('Not found');
    }
}

const server = http.createServer((req, res) => {
    const url = new URL(req.url, `http://localhost:${port}`);
    const path = url.pathname;
    
    console.log(`[${req.method}] ${path}`);
    
    if (path === '/') {
        sendHtml(res, htmlFile);
    } else if (path === '/api/status') {
        const config = getConfig();
        const state = getState();
        
        const data = {
            running: true, // 简化处理
            version: '2026.2.21-2',
            bindMode: config.gateway?.bind || 'loopback',
            workspace: config.agents?.defaults?.workspace || baseDir,
            startCount: state.startCount,
            startTime: state.startTime,
            currentModel: config.agents?.defaults?.model?.primary || 'unicom/glm-5',
            msgCount: state.msgCount,
            tokenUsed: state.tokenUsed,
            activeChannels: [{ name: 'Feishu', status: 'Connected', enabled: config.channels?.feishu?.enabled || true }]
        };
        
        sendJson(res, data);
    } else if (path === '/api/ai/chat' && req.method === 'POST') {
        let body = '';
        req.on('data', chunk => {
            body += chunk.toString();
        });
        req.on('end', () => {
            try {
                const jsonBody = JSON.parse(body);
                const message = jsonBody.message;
                const model = jsonBody.model;
                
                const responseText = `我是OpenClaw AI助手，收到了你的消息：'${message}'`;
                
                sendJson(res, { reply: responseText });
            } catch (error) {
                console.error('AI Chat Error:', error);
                sendJson(res, { reply: '抱歉，处理你的请求时出现错误。' });
            }
        });
    } else {
        res.writeHead(404);
        res.end('Not found');
    }
});

server.listen(port, 'localhost', () => {
    console.log('========================================');
    console.log('  OpenClaw Panel Server v2.0 Started');
    console.log('========================================');
    console.log(`URL: http://localhost:${port}`);
    console.log('Press Ctrl+C to stop');
});