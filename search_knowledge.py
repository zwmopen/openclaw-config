import os
import re
from pathlib import Path

# 搜索关键词
keywords = ["高版本", "碎片", "个人形象", "身高", "体重", "运动计划", "人际关系", "积极主动", "简历", "代运营"]

# 知识库路径
knowledge_base = r"D:\Program Files\Obsidian\zwm\.zwm\个人知识库"

# 搜索结果
results = {}

for keyword in keywords:
    results[keyword] = []
    for root, dirs, files in os.walk(knowledge_base):
        for file in files:
            if file.endswith(('.md', '.txt', '.xlsx')):
                file_path = os.path.join(root, file)
                try:
                    if file.endswith('.md') or file.endswith('.txt'):
                        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                            content = f.read()
                            if keyword in content:
                                # 提取包含关键词的段落
                                paragraphs = content.split('\n\n')
                                for para in paragraphs:
                                    if keyword in para:
                                        results[keyword].append({
                                            'file': file_path,
                                            'content': para[:500]  # 只取前500字符
                                        })
                except Exception as e:
                    pass

# 输出结果
for keyword, matches in results.items():
    if matches:
        print(f"\n{'='*60}")
        print(f"关键词：{keyword}")
        print(f"找到 {len(matches)} 条结果")
        print('='*60)
        for i, match in enumerate(matches[:5]):  # 只显示前5条
            print(f"\n[{i+1}] {match['file']}")
            print(f"内容：{match['content'][:200]}...")
