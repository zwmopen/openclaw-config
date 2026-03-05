# -*- coding: utf-8 -*-
import csv
import json
import sys
from collections import defaultdict

# 设置输出编码
sys.stdout.reconfigure(encoding='utf-8')

# 读取CSV文件
tasks = []
with open(r'C:\Users\z\Downloads\backup.csv', 'r', encoding='utf-8-sig') as f:
    reader = csv.DictReader(f)
    for row in reader:
        tasks.append(row)

print(f'总任务数: {len(tasks)}')

# 统计
folders = defaultdict(int)
lists = defaultdict(int)
status_count = defaultdict(int)
repeat_tasks = []

for task in tasks:
    folder = task.get('Folder Name', '').strip()
    list_name = task.get('List Name', '').strip()
    status = task.get('Status', '').strip()
    repeat = task.get('Repeat', '').strip()
    
    if folder:
        folders[folder] += 1
    if list_name:
        lists[list_name] += 1
    status_count[status] += 1
    
    # 提取循环任务
    if repeat and 'FREQ=' in repeat:
        repeat_tasks.append({
            'title': task.get('Title', ''),
            'list': list_name,
            'repeat': repeat,
            'status': status,
            'content': task.get('Content', '')[:200] if task.get('Content') else ''
        })

print('\n=== 状态统计 ===')
print(f'正常任务(0): {status_count.get("0", 0)}')
print(f'已完成(1): {status_count.get("1", 0)}')
print(f'已归档(2): {status_count.get("2", 0)}')

print('\n=== 文件夹分布（前10） ===')
for folder, count in sorted(folders.items(), key=lambda x: x[1], reverse=True)[:10]:
    print(f'{folder}: {count}条')

print('\n=== 列表分布（前15） ===')
for list_name, count in sorted(lists.items(), key=lambda x: x[1], reverse=True)[:15]:
    print(f'{list_name}: {count}条')

print(f'\n=== 循环任务（每日/每周/每月）共{len(repeat_tasks)}个 ===')
daily = [t for t in repeat_tasks if 'DAILY' in t['repeat']]
weekly = [t for t in repeat_tasks if 'WEEKLY' in t['repeat']]
monthly = [t for t in repeat_tasks if 'MONTHLY' in t['repeat']]

print(f'每日任务: {len(daily)}个')
print(f'每周任务: {len(weekly)}个')
print(f'每月任务: {len(monthly)}个')

# 显示每日任务（正常状态）
print('\n=== 正在进行的每日任务 ===')
for t in daily:
    if t['status'] == '0':
        content_preview = t['content'][:50] + '...' if len(t['content']) > 50 else t['content']
        print(f'- [{t["list"]}] {t["title"]}')
        if content_preview:
            print(f'  内容: {content_preview}')

# 显示每周任务
print('\n=== 每周任务 ===')
for t in weekly[:20]:
    if t['status'] == '0':
        print(f'- [{t["list"]}] {t["title"]}')

# 显示每月任务
print('\n=== 每月任务 ===')
for t in monthly[:20]:
    if t['status'] == '0':
        print(f'- [{t["list"]}] {t["title"]}')

# 提取有价值的内容（Content字段超过100字的任务）
print('\n=== 有价值的任务内容（内容超过100字） ===')
valuable_tasks = []
for task in tasks:
    content = task.get('Content', '').strip()
    if len(content) > 100:
        valuable_tasks.append({
            'title': task.get('Title', ''),
            'list': task.get('List Name', ''),
            'content': content[:500],  # 截取前500字
            'created': task.get('Created Time', '')
        })

print(f'共找到 {len(valuable_tasks)} 条有价值的任务内容')

# 保存到JSON文件供后续处理
output = {
    'total_tasks': len(tasks),
    'status_count': dict(status_count),
    'folders': dict(folders),
    'lists': dict(lists),
    'daily_tasks': daily,
    'weekly_tasks': weekly,
    'monthly_tasks': monthly,
    'valuable_tasks': valuable_tasks[:100]  # 只保存前100条
}

with open(r'D:\AI编程\openclaw\scripts\dida_analysis.json', 'w', encoding='utf-8') as f:
    json.dump(output, f, ensure_ascii=False, indent=2)

print('\n分析结果已保存到: D:\\AI编程\\openclaw\\scripts\\dida_analysis.json')
