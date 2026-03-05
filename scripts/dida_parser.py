#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""滴答清单备份文件解析器"""

import csv
import io
import json
from datetime import datetime
import chardet

# 读取CSV（自动检测编码）
with open(r'C:\Users\z\Downloads\backup.csv', 'rb') as f:
    raw = f.read()
    detected = chardet.detect(raw)
    print(f"检测到编码: {detected['encoding']} (置信度: {detected['confidence']})")
    content = raw.decode(detected['encoding'] or 'utf-8')
    lines = content.splitlines()

# 表头在第6行（索引6），数据从第7行开始
content_from_header = '\n'.join(lines[6:])
reader = csv.DictReader(io.StringIO(content_from_header))
raw_rows = list(reader)

# 清理字段名（去除引号）
rows = []
for row in raw_rows:
    cleaned_row = {}
    for k, v in row.items():
        clean_key = k.strip('"\'') if k else k
        cleaned_row[clean_key] = v
    rows.append(cleaned_row)

print(f"总行数: {len(lines)}, 数据行数: {len(rows)}")

# 统计数据
stats = {
    'total': len(rows),
    'folders': {},
    'lists': {},
    'tags': {},
    'daily_tasks': [],
    'weekly_tasks': [],
    'monthly_tasks': [],
    'with_content': [],
    'high_priority': [],
    'completed': 0,
    'archived': 0,
    'normal': 0
}

# 分析每条任务
for row in rows:
    title = row.get('Title', '').strip()
    folder = row.get('Folder Name', '').strip()
    lst = row.get('List Name', '').strip()
    tags = row.get('Tags', '').strip()
    content = row.get('Content', '').strip()
    repeat = row.get('Repeat', '').strip()
    status = row.get('Status', '').strip()
    priority = row.get('Priority', '0').strip()
    created = row.get('Created Time', '').strip()
    
    # 文件夹统计
    if folder:
        stats['folders'][folder] = stats['folders'].get(folder, 0) + 1
    
    # 列表统计
    if lst:
        stats['lists'][lst] = stats['lists'].get(lst, 0) + 1
    
    # 标签统计
    if tags:
        for tag in tags.split(','):
            tag = tag.strip()
            if tag:
                stats['tags'][tag] = stats['tags'].get(tag, 0) + 1
    
    # 状态统计
    if status == '0':
        stats['normal'] += 1
    elif status == '1':
        stats['completed'] += 1
    elif status == '2':
        stats['archived'] += 1
    
    # 重复任务
    task_info = {
        'title': title,
        'content': content[:300] if content else '',
        'list': lst,
        'folder': folder,
        'tags': tags
    }
    
    if 'FREQ=DAILY' in repeat:
        stats['daily_tasks'].append(task_info)
    elif 'FREQ=WEEKLY' in repeat:
        stats['weekly_tasks'].append(task_info)
    elif 'FREQ=MONTHLY' in repeat:
        stats['monthly_tasks'].append(task_info)
    
    # 有详细内容的任务（价值内容）
    if len(content) > 50:
        stats['with_content'].append({
            'title': title,
            'content': content[:500],
            'list': lst,
            'folder': folder,
            'tags': tags,
            'created': created,
            'status': status
        })
    
    # 高优先级任务
    if priority in ['1', '2']:
        stats['high_priority'].append({
            'title': title,
            'content': content[:200] if content else '',
            'list': lst,
            'priority': priority
        })

# 生成报告
output = []
output.append('=' * 80)
output.append('滴答清单备份文件分析报告')
output.append('=' * 80)
output.append(f'分析时间: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}')
output.append('')
output.append(f'📊 总任务数: {stats["total"]}')
output.append(f'  - 正常任务: {stats["normal"]}')
output.append(f'  - 已完成: {stats["completed"]}')
output.append(f'  - 已归档: {stats["archived"]}')
output.append('')

output.append('📁 文件夹分布 (前20):')
for folder, count in sorted(stats['folders'].items(), key=lambda x: -x[1])[:20]:
    output.append(f'  {folder}: {count}')
output.append('')

output.append('📋 列表分布 (前20):')
for lst, count in sorted(stats['lists'].items(), key=lambda x: -x[1])[:20]:
    output.append(f'  {lst}: {count}')
output.append('')

output.append('🏷️ 标签分布 (前20):')
for tag, count in sorted(stats['tags'].items(), key=lambda x: -x[1])[:20]:
    output.append(f'  {tag}: {count}')
output.append('')

output.append(f'🔄 每日循环任务 ({len(stats["daily_tasks"])}条):')
for task in stats['daily_tasks'][:50]:
    output.append(f'  - [{task["list"]}] {task["title"]}')
    if task['content']:
        output.append(f'    内容: {task["content"][:100]}...')
output.append('')

output.append(f'📅 每周循环任务 ({len(stats["weekly_tasks"])}条):')
for task in stats['weekly_tasks'][:30]:
    output.append(f'  - [{task["list"]}] {task["title"]}')
output.append('')

output.append(f'📆 每月循环任务 ({len(stats["monthly_tasks"])}条):')
for task in stats['monthly_tasks'][:20]:
    output.append(f'  - [{task["list"]}] {task["title"]}')
output.append('')

output.append(f'📝 有详细内容的任务 ({len(stats["with_content"])}条):')
output.append('显示前100条最有价值的任务内容...')
for task in stats['with_content'][:100]:
    status_text = {'0': '正常', '1': '完成', '2': '归档'}.get(task['status'], '未知')
    output.append(f'\n【{status_text}】[{task["list"]}] {task["title"]}')
    output.append(f'  创建时间: {task["created"]}')
    output.append(f'  标签: {task["tags"]}')
    output.append(f'  内容: {task["content"]}')
    output.append('-' * 40)

# 保存结果
result_text = '\n'.join(output)
with open(r'D:\AI编程\openclaw\滴答清单分析报告.txt', 'w', encoding='utf-8') as f:
    f.write(result_text)

# 保存JSON数据（用于后续迁移）
with open(r'D:\AI编程\openclaw\滴答清单数据.json', 'w', encoding='utf-8') as f:
    json.dump({
        'stats': {
            'total': stats['total'],
            'normal': stats['normal'],
            'completed': stats['completed'],
            'archived': stats['archived'],
            'folders': stats['folders'],
            'lists': stats['lists'],
            'tags': stats['tags']
        },
        'daily_tasks': stats['daily_tasks'],
        'weekly_tasks': stats['weekly_tasks'],
        'monthly_tasks': stats['monthly_tasks'],
        'with_content': stats['with_content'][:200]
    }, f, ensure_ascii=False, indent=2)

# 只输出数字
print('OK')
print(stats['total'])
print(len(stats['daily_tasks']))
print(len(stats['weekly_tasks']))
print(len(stats['monthly_tasks']))
print(len(stats['with_content']))
