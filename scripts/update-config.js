const fs = require('fs');
const path = require('path');

const configPath = path.join(process.env.USERPROFILE, '.openclaw', 'openclaw.json');
const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));

config.models.providers['zhipu-official'] = {
  baseUrl: 'https://open.bigmodel.cn/api/paas/v4/',
  apiKey: 'aaba2e5167954bac8fb2188d882c40db.qP2yJKa6qjLA16XA',
  api: 'openai-completions',
  models: [
    {
      id: 'glm-4-flash',
      name: 'GLM-4-Flash (智谱官网)',
      reasoning: false,
      input: ['text'],
      contextWindow: 128000,
      maxTokens: 4096,
      cost: { input: 0, output: 0 },
      compat: { supportsDeveloperRole: false }
    }
  ]
};

config.models.providers.unicom.models[0] = {
  id: 'glm-5',
  name: 'GLM-5 (联通元景)',
  reasoning: false,
  input: ['text'],
  contextWindow: 128000,
  maxTokens: 4096,
  cost: { input: 0, output: 0 },
  compat: { supportsDeveloperRole: false }
};

fs.writeFileSync(configPath, JSON.stringify(config, null, 2), 'utf8');
console.log('配置已更新！');
console.log('已添加智谱AI官网配置: zhipu-official/glm-4-flash');
console.log('已更新联通元景配置: unicom/glm-5');
