const fs = require('fs');
const path = require('path');

const basePath = 'D:\\Program Files\\Obsidian\\zwm\\.zwm\\02-ZWM 2.0 内容生产系统\\01-内容生产';

// 重命名映射（旧名 → 新名）
const renameMap = {
  '00-口述采集': '01-素材采集',
  '03-内容素材库': '02-内容素材库',
  '01-选题管理': '03-选题管理',
  '02-选题研究': '04-选题研究',
  '01-深化产出': '05-内容创作',
  '02-待发布': '06-待发布',
  '03-已发布': '07-已发布',
  '06-内容数据统计': '08-数据追踪',
  '04-方法论沉淀': '09-方法论沉淀',
  '05-工具与资源': '10-工具与资源'
};

console.log('开始重命名...\n');

// 第一步：重命名到临时名称（避免冲突）
const tempNames = {};
for (const [oldName, newName] of Object.entries(renameMap)) {
  const tempName = 'temp-' + newName;
  tempNames[tempName] = newName;
  const oldPath = path.join(basePath, oldName);
  const tempPath = path.join(basePath, tempName);
  
  if (fs.existsSync(oldPath)) {
    fs.renameSync(oldPath, tempPath);
    console.log(`临时重命名: ${oldName} → ${tempName}`);
  }
}

console.log('\n');

// 第二步：重命名到最终名称
for (const [tempName, newName] of Object.entries(tempNames)) {
  const tempPath = path.join(basePath, tempName);
  const newPath = path.join(basePath, newName);
  
  if (fs.existsSync(tempPath)) {
    fs.renameSync(tempPath, newPath);
    console.log(`最终重命名: ${tempName} → ${newName}`);
  }
}

console.log('\n重命名完成！\n');

// 显示新结构
console.log('新文件夹结构：');
const dirs = fs.readdirSync(basePath, { withFileTypes: true })
  .filter(d => d.isDirectory())
  .map(d => d.name)
  .sort();

dirs.forEach(d => console.log('- ' + d));
