const fs = require('fs');
const path = require('path');

const targetPath = 'D:\\Program Files\\Obsidian\\zwm\\.zwm\\个人知识库\\印象笔记\\1-1收集箱（历史欠账）';

function scanFiles(dir) {
    let results = [];
    const items = fs.readdirSync(dir, { withFileTypes: true });
    
    for (const item of items) {
        const fullPath = path.join(dir, item.name);
        if (item.isDirectory()) {
            results = results.concat(scanFiles(fullPath));
        } else if (item.name.endsWith('.md')) {
            results.push(fullPath);
        }
    }
    return results;
}

function main() {
    const allFiles = scanFiles(targetPath);
    const processedFiles = allFiles.filter(f => path.basename(f).includes('已梳理'));
    
    // 筛选待处理文件
    const candidates = [];
    for (const file of allFiles) {
        const name = path.basename(file);
        // 跳过已梳理、2020-、21天
        if (name.includes('已梳理') || name.includes('2020-') || name.includes('21天')) {
            continue;
        }
        
        try {
            const content = fs.readFileSync(file, 'utf8');
            const len = content.length;
            if (len >= 2000 && len <= 15000) {
                candidates.push({ name, path: file, length: len });
            }
        } catch (e) {
            // 忽略读取错误
        }
    }
    
    // 按字符数排序
    candidates.sort((a, b) => b.length - a.length);
    
    console.log(JSON.stringify({
        total: allFiles.length,
        processed: processedFiles.length,
        pending: candidates.length,
        rate: ((processedFiles.length / allFiles.length) * 100).toFixed(1),
        next10: candidates.slice(0, 10)
    }, null, 2));
}

main();
