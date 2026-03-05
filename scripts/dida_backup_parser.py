#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""滴答清单备份文件解析器"""

import csv
import io
import json
from datetime import datetime

# 读取CSV
print('正在读取CSV文件...')
with open(r'C:\Users\z\Downloads\backup.csv', 'r', encoding='utf-8-sig') as f:
    lines = f.readlines()

print(f'总行数: {len(lines)}')

# 查看表头行（调试）
print(f'第6行（表头）: {lines[5][:200]}')

# 解析CSV（跳过前4行元数据，第5行是表头）
content = ''.join(lines[5:])
reader = csv.DictReader(io.StringIO(content))
rows = list(reader)

# 查看字段名
print(f'字段名: {list(rows[0].keys())[:5]}...')

print(f'总任务数: {len(rows)}')

# 统计
stats = {
    'total': len(rows),
    'folders': {},
    'lists': {},
    'tags': {},
    'status': {0: '正常', 1: '完成', 2: '归档'},
    'repeat': {'daily': [], 'weekly': [], 'monthly': []},
    'with_content': [],
    'high_priority': []
}

# 分析每条任务
for row in rows:
    # 文件夹统计
    folder = row.get('Folder Name', '').strip()
    if folder:
        stats['folders'][folder] = stats['folders'].get(folder, 0) + 1
    
    # 列表统计
    lst = row.get('List Name', '').strip()
    if lst:
        stats['lists'][lst] = stats['lists'].get(lst, 0) + 1
    
    # 标签统计
    tags = row.get('Tags', '').strip()
    if tags:
        for tag in tags.split(','):
            tag = tag.strip()
            if tag:
                stats['tags'][tag] = stats['tags'].get(tag, 0) + 1
    
    # 重复任务
    repeat = row.get('Repeat', '').strip()
    title = row.get('Title', '').strip()
    if 'FREQ=DAILY' in repeat:
        stats['repeat']['daily'].append({
            'title': title,
            'content': row.get('Content', '').strip()[:200],
            'list': lst,
            'folder': folder
        })
    elif 'FREQ=WEEKLY' in repeat:
        stats['repeat']['weekly'].append({
            'title': title,
            'content': row.get('Content', '').strip()[:200],
            'list': lst,
            'folder': folder
        })
    elif 'FREQ=MONTHLY' in repeat:
        stats['repeat']['monthly'].append({
            'title': title,
            'content': row.get('Content', '').strip()[:200],
            'list': lst,
            'folder': folder
        })
    
    # 有内容的任务（价值内容）
    content = row.get('Content', '').strip()
    if len(content) > 50:  # 内容超过50字的任务
        stats['with_content'].append({
            'title': title,
            'content': content[:500],
            'list': lst,
            'folder': folder,
            'tags': tags,
            'created': row.get('Created Time', ''),
            'status': row.get('Status', '')
        })
    
    # 高优先级任务
    priority = row.get('Priority', '0')
    if priority == '1' or priority == '2':  # 中优先级或高优先级
        stats['high_priority'].append({
            'title': title,
            'content': content[:200],
            'list': lst,
            'priority': priority
        })

# 输出结果
output = []
output.append('=' * 80)
output.append('滴答清单备份文件分析报告')
output.append('=' * 80)
output.append(f'分析时间: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}')
output.append(f'总任务数: {stats["total"]}')
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

output.append(f'🔄 每日循环任务 ({len(stats["repeat"]["daily"])}条):')
for task in stats['repeat']['daily'][:30]:
    output.append(f'  - [{task["list"]}] {task["title"]}')
    if task['content']:
        output.append(f'    内容: {task["content"][:100]}...')
output.append('')

output.append(f'📅 每周循环任务 ({len(stats["repeat"]["weekly"])}条):')
for task in stats['repeat']['weekly'][:20]:
    output.append(f'  - [{task["list"]}] {task["title"]}')
output.append('')

output.append(f'📆 每月循环任务 ({len(stats["repeat"]["monthly"])}条):')
for task in stats['repeat']['monthly'][:20]:
    output.append(f'  - [{task["list"]}] {task["title"]}')
output.append('')

output.append(f'📝 有详细内容的任务 ({len(stats["with_content"])}条，前50条):')
for task in stats['with_content'][:50]:
    status_text = {'0': '正常', '1': '完成', '2': '归档'}.get(task['status'], '未知')
    output.append(f'  - [{status_text}] [{task["list"]}] {task["title"]}')
    output.append(f'    内容: {task["content"][:150]}...')
    output.append('')

# 保存结果
result_text = '\n'.join(output)
with open(r'D:\AI编程\openclaw\滴答清单分析报告.txt', 'w', encoding='utf-8') as f:
    f.write(result_text)

# 保存JSON数据（用于后续处理）
with open(r'D:\AI编程\openclaw\滴答清单数据.json', 'w', encoding='utf-8') as f:
    json.dump({
        'stats': {
            'total': stats['total'],
            'folders': stats['folders'],
            'lists': stats['lists'],
            'tags': stats['tags']
        },
        'daily_tasks': stats['repeat']['daily'],
        'weekly_tasks': stats['repeat']['weekly'],
        'monthly_tasks': stats['repeat']['monthly'],
        'with_content': stats['with_content'][:200]  # 只保存前200条有价值内容
    }, f, ensure_ascii=False, indent=2)

print('分析完成！')
print(f'报告已保存到: D:\\AI编程\\openclaw\\滴答清单分析报告.txt')
print(f'数据已保存到: D:\\AI编程\\openclaw\\滴答清单数据.json')
