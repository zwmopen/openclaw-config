import os

base = r'D:\Program Files\Obsidian\zwm\.zwm\个人知识库'
found_files = []

for root, dirs, files in os.walk(base):
    for f in files:
        if f.endswith('.md'):
            full_path = os.path.join(root, f)
            if 'Project me' in f or '高版本' in f:
                found_files.append(full_path)

for path in found_files:
    print(f'\n{"="*80}')
    print(f'文件: {path}')
    print('-'*80)
    try:
        with open(path, 'r', encoding='utf-8') as f:
            content = f.read()
            print(content[:5000])
    except Exception as e:
        print(f'读取失败: {e}')
