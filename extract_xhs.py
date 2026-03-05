# -*- coding: utf-8 -*-
import re
import html

with open(r'D:\Program Files\Obsidian\zwm\zwm\00-收件箱\素材\小红书测试.html', 'r', encoding='utf-8') as f:
    content = f.read()

# 提取标题
title_match = re.search(r'<title>([^<]+)</title>', content)
title = title_match.group(1) if title_match else '未知标题'

# 提取描述
desc_match = re.search(r'name="description" content="([^"]+)"', content)
desc = desc_match.group(1) if desc_match else ''

# 清理描述
desc = html.unescape(desc)
desc = re.sub(r'<[^>]+>', '', desc)

# 保存为 Markdown
output = f'''# {title}

> 来源: 小红书
> 链接: http://xhslink.com/o/19X2pdhv4Zp
> 抓取时间: 2026-03-03

---

{desc}

---

**标签**: #AI #自媒体 #小红书
'''

output_path = r'D:\Program Files\Obsidian\zwm\zwm\00-收件箱\素材\造了个女博主让她自己更新小红书.md'
with open(output_path, 'w', encoding='utf-8') as f:
    f.write(output)

print('Saved to:', output_path)
print('Title length:', len(title))
print('Desc length:', len(desc))
