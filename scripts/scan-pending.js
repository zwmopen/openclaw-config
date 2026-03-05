const fs = require('fs');
const path = require('path');

const dir = 'D:\\Program Files\\Obsidian\\zwm\\.zwm\\个人知识库\\印象笔记\\1-1收集箱（历史欠账）';
const files = fs.readdirSync(dir).filter(f => f.endsWith('.md'));

const pending = [];
for (const file of files) {
  // 跳过已梳理
  if (file.includes('已梳理')) continue;
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

console.log('待处理文件数:', pending.length);
console.log('\n前30个待处理:');
pending.slice(0, 30).forEach((p, i) => {
  console.log(`${i+1}. ${p.file} (${p.len}字)`);
});

// 保存完整列表
fs.writeFileSync('D:\\AI编程\\openclaw\\scripts\\pending-list.json', JSON.stringify(pending, null, 2));
console.log('\n完整列表已保存到 pending-list.json');
