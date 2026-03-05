const fs = require('fs');
const path = require('path');

const dir = 'D:\\Program Files\\Obsidian\\zwm\\.zwm\\个人知识库\\印象笔记\\1-1收集箱（历史欠账）';
const files = fs.readdirSync(dir).filter(f => f.endsWith('.md'));

const pending = [];
const processed = [];

for (const file of files) {
  // 跳过已梳理
  if (file.includes('已梳理')) {
    processed.push(file);
    continue;
  }
  // 跳过2020年
  if (file.includes('2020-')) continue;
  // 跳过21天
  if (file.includes('21天')) continue;
  
  const filePath = path.join(dir, file);
  const content = fs.readFileSync(filePath, 'utf-8');
  const len = content.length;
  
  // 字符数2000-15000
  if (len >= 2000 && len <= 15000) {
    pending.push({ file, len });
  }
}

// 检查哪些已处理
const needProcess = [];
for (const p of pending) {
  const processedPath = path.join(dir, p.file.replace('.md', '（已梳理）.md'));
  if (!fs.existsSync(processedPath)) {
    needProcess.push(p);
  }
}

console.log('已梳理文件数:', processed.length);
console.log('待处理(符合条件):', pending.length);
console.log('实际需要处理(未生成梳理版):', needProcess.length);
console.log('\n前10个需要处理:');
needProcess.slice(0, 10).forEach((p, i) => {
  console.log(`${i+1}. ${p.file} (${p.len}字)`);
});

// 保存待处理列表
fs.writeFileSync('D:\\AI编程\\openclaw\\scripts\\need-process.json', JSON.stringify(needProcess, null, 2));
console.log('\n完整列表已保存到 need-process.json');
