# -*- coding: utf-8 -*-
import json
import os
import re
from pathlib import Path
from datetime import datetime

BASE_PATH = Path(r"D:\Program Files\Obsidian\zwm\.zwm")
STATE_FILE = BASE_PATH / "02-ZWM 2.0 内容生产系统" / "01-内容生产" / "03-内容素材库" / "扫描状态.json"
KB_PATH = BASE_PATH / "个人知识库"
QUOTE_FILE = BASE_PATH / "02-ZWM 2.0 内容生产系统" / "01-内容生产" / "03-内容素材库" / "金句库.md"
CONCEPT_FILE = BASE_PATH / "02-ZWM 2.0 内容生产系统" / "01-内容生产" / "03-内容素材库" / "核心概念库.md"

DIRS = ["01-flomo闪念", "02-我的幕布", "03-微信读书", "04-和AI聊天的库", "05-印象笔记", "06-飞书批量导出"]

def is_quote(text):
    """检查是否是金句"""
    if len(text) < 5 or len(text) > 100:
        return False
    
    keywords = ['不是', '而是', '决定', '本质', '核心', '关键', '像', '就是', '认知', '财富', '价值', '规律']
    if not any(kw in text for kw in keywords):
        return False
    
    patterns = [
        r'不是.+而是',
        r'不是.+是',
        r'.+的本质是',
        r'.+决定.+',
        r'.+像.+',
        r'.+就是.+',
        r'你(赚不到|得不到|无法).+认知',
        r'(不要|别).+要',
        r'.+的边界是.+的边界',
    ]
    
    for pattern in patterns:
        if re.search(pattern, text):
            return True
    return False

def is_concept(title, content):
    """检查是否是概念"""
    if len(title) < 3 or len(title) > 50:
        return False
    if len(content) < 200:
        return False
    
    keywords = ['法则', '定律', '原理', '方法', '技巧', '模型', '思维', '框架', '策略', '原则', '理论', '体系', '系统', '认知', '概念', '本质', '规律']
    return any(kw in title for kw in keywords)

def scan_batch(batch_size=50):
    """扫描一批文件"""
    # 读取状态
    with open(STATE_FILE, 'r', encoding='utf-8') as f:
        state = json.load(f)
    
    if state['status'] != 'running':
        print(f"Status: {state['status']}")
        return
    
    # 获取文件列表
    current_dir = state['currentDir']
    scanned = state['scanned']
    
    dir_path = KB_PATH / current_dir
    if not dir_path.exists():
        # 切换到下一个目录
        idx = DIRS.index(current_dir)
        if idx < len(DIRS) - 1:
            state['currentDir'] = DIRS[idx + 1]
            state['scanned'] = 0
            current_dir = DIRS[idx + 1]
            scanned = 0
            dir_path = KB_PATH / current_dir
        else:
            state['status'] = 'completed'
            with open(STATE_FILE, 'w', encoding='utf-8') as f:
                json.dump(state, f, ensure_ascii=False, indent=2)
            print("Status: completed")
            return
    
    # 获取文件
    files = list(dir_path.rglob("*.md"))
    batch = files[scanned:scanned + batch_size]
    
    if not batch:
        # 切换到下一个目录
        idx = DIRS.index(current_dir)
        if idx < len(DIRS) - 1:
            state['currentDir'] = DIRS[idx + 1]
            state['scanned'] = 0
        else:
            state['status'] = 'completed'
        with open(STATE_FILE, 'w', encoding='utf-8') as f:
            json.dump(state, f, ensure_ascii=False, indent=2)
        print(f"Status: {'completed' if state['status'] == 'completed' else 'next_dir'}")
        return
    
    quotes = []
    concepts = []
    
    for file in batch:
        try:
            content = file.read_text(encoding='utf-8')
            
            # 提取概念
            match = re.match(r'^#\s+(.+)', content, re.MULTILINE)
            if match and is_concept(match.group(1), content):
                concepts.append(match.group(1).strip())
            
            # 提取金句
            sentences = re.split(r'[。！？\n]', content)
            for s in sentences:
                s = s.strip()
                if is_quote(s):
                    quotes.append(s)
        except:
            pass
    
    # 去重
    quotes = list(set(quotes))
    
    # 更新状态
    state['scanned'] += len(batch)
    state['quotes']['completed'] += len(quotes)
    state['concepts']['completed'] += len(concepts)
    state['quotes']['progress'] = f"{round(state['quotes']['completed'] / state['quotes']['target'] * 100, 1)}%"
    state['concepts']['progress'] = f"{round(state['concepts']['completed'] / state['concepts']['target'] * 100, 1)}%"
    state['lastUpdate'] = datetime.now().strftime('%Y-%m-%d %H:%M')
    state['totalScans'] = state.get('totalScans', 0) + 1
    
    with open(STATE_FILE, 'w', encoding='utf-8') as f:
        json.dump(state, f, ensure_ascii=False, indent=2)
    
    # 追加金句
    if quotes:
        with open(QUOTE_FILE, 'a', encoding='utf-8') as f:
            f.write(f"\n\n### 扫描提取 - {state['lastUpdate']}\n\n")
            for q in quotes:
                f.write(f'> "{q}"\n\n')
    
    # 输出
    print(f"Scanned: {len(batch)} files")
    print(f"Quotes: +{len(quotes)} (Total: {state['quotes']['completed']})")
    print(f"Concepts: +{len(concepts)} (Total: {state['concepts']['completed']})")
    print(f"Progress: {state['scanned']}/{state['total']} ({round(state['scanned']/state['total']*100, 1)}%)")
    print(f"Dir: {current_dir}")
    
    # 汇报节点
    if state['scanned'] % 200 == 0:
        print("[REPORT]")

if __name__ == "__main__":
    import sys
    batch_size = int(sys.argv[1]) if len(sys.argv) > 1 else 50
    scan_batch(batch_size)
