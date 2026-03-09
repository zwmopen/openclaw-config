import re

with open(r'D:\Program Files\Obsidian\zwm\.zwm\个人成长\碎片库.md', 'r', encoding='utf-8') as f:
    content = f.read()
    
headers = re.findall(r'^(##+ .+)$', content, re.MULTILINE)

for h in headers:
    print(h)
