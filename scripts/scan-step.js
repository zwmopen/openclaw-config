const fs = require('fs');
const path = require('path');

const stateFile = 'D:\\Program Files\\Obsidian\\zwm\\.zwm\\02-ZWM 2.0 内容生产系统\\01-内容生产\\03-内容素材库\\扫描状态.json';
const kbPath = 'D:\\Program Files\\Obsidian\\zwm\\.zwm\\个人知识库';

const dirs = ['01-flomo闪念', '02-我的幕布', '03-微信读书', '04-和AI聊天的库', '05-印象笔记', '06-飞书批量导出'];

// Read state
const state = JSON.parse(fs.readFileSync(stateFile, 'utf8'));

console.log('Status:', state.status);
console.log('Current Dir:', state.currentDir);
console.log('Scanned:', state.scanned + '/' + state.total);
console.log('Concepts:', state.concepts.completed + '/' + state.concepts.target, '(' + state.concepts.progress + ')');
console.log('Quotes:', state.quotes.completed + '/' + state.quotes.target, '(' + state.quotes.progress + ')');
console.log('Cases:', state.cases.completed + '/' + state.cases.target, '(' + state.cases.progress + ')');

if (state.status !== 'running') {
  console.log('\nScan is not running.');
  process.exit(0);
}

// Get files
const currentDir = state.currentDir;
const dirPath = path.join(kbPath, currentDir);

function getAllMdFiles(dir) {
  const files = [];
  const items = fs.readdirSync(dir, { withFileTypes: true });
  for (const item of items) {
    const fullPath = path.join(dir, item.name);
    if (item.isDirectory()) {
      files.push(...getAllMdFiles(fullPath));
    } else if (item.name.endsWith('.md')) {
      files.push(fullPath);
    }
  }
  return files;
}

const allFiles = getAllMdFiles(dirPath);
const files = allFiles.slice(state.scanned, state.scanned + 50);

console.log('\nFiles to scan:', files.length);

if (files.length === 0) {
  const idx = dirs.indexOf(currentDir);
  if (idx < dirs.length - 1) {
    state.currentDir = dirs[idx + 1];
    state.scanned = 0;
    console.log('Switch to:', state.currentDir);
  } else {
    state.status = 'completed';
    console.log('Scan completed!');
  }
} else {
  let concepts = 0;
  let quotes = 0;
  let cases = 0;

  for (const file of files) {
    try {
      const content = fs.readFileSync(file, 'utf8');
      if (/(本质|规律|原则|核心|底层逻辑|第一性原理|方法论|关键|重要)/.test(content)) concepts++;
      if (/(所谓|真正的|重要的|关键的|记住|明白|发现|其实|不是.*而是|因为.*所以|只有.*才|没有.*就)/.test(content)) quotes++;
      if (/(案例|例子|故事|经历|实践|实操|落地|应用)/.test(content)) cases++;
    } catch (e) {
      // Skip errors
    }
  }

  state.scanned += files.length;
  state.concepts.completed += concepts;
  state.quotes.completed += quotes;
  state.cases.completed += cases;
  state.concepts.progress = (state.concepts.completed / state.concepts.target * 100).toFixed(1) + '%';
  state.quotes.progress = (state.quotes.completed / state.quotes.target * 100).toFixed(1) + '%';
  state.cases.progress = (state.cases.completed / state.cases.target * 100).toFixed(1) + '%';
  state.lastScanCount = files.length;
  state.totalScans++;
  state.lastUpdate = new Date().toISOString().slice(0, 16).replace('T', ' ');

  const progress = (state.scanned / state.total * 100).toFixed(1);
  console.log('\nScanned:', files.length, 'files');
  console.log('Concepts: +' + concepts, '(Total:', state.concepts.completed + '/' + state.concepts.target + ')');
  console.log('Quotes: +' + quotes, '(Total:', state.quotes.completed + '/' + state.quotes.target + ')');
  console.log('Cases: +' + cases, '(Total:', state.cases.completed + '/' + state.cases.target + ')');
  console.log('Progress:', state.scanned + '/' + state.total, '(' + progress + '%)');
}

// Save state
fs.writeFileSync(stateFile, JSON.stringify(state, null, 2), 'utf8');
console.log('\nState saved.');
