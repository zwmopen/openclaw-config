# PDF任务提取脚本

import PyPDF2
import re
from datetime import datetime

def extract_text_from_pdf(pdf_path):
    """从PDF提取文本"""
    text = ""
    try:
        with open(pdf_path, 'rb') as file:
            reader = PyPDF2.PdfReader(file)
            for page_num in range(len(reader.pages)):
                page = reader.pages[page_num]
                text += page.extract_text()
        print(f"✅ 成功提取 PDF 内容")
        return text
    except Exception as e:
        print(f"❌ 提取失败: {e}")
        return ""

def parse_tasks(text):
    """解析任务信息"""
    tasks = []
    
    # 按行分割
    lines = text.split('\n')
    
    current_task = None
    current_subtasks = []
    current_notes = []
    
    for line in lines:
        line = line.strip()
        if not line:
            continue
        
        # 检测主任务（以数字或特殊符号开头）
        if re.match(r'^\d+\.|^-|^\*|^\[.+\]', line):
            # 保存之前的任务
            if current_task:
                tasks.append({
                    'title': current_task,
                    'subtasks': current_subtasks,
                    'notes': current_notes
                })
            
            # 开始新任务
            current_task = line
            current_subtasks = []
            current_notes = []
        
        # 检测子任务（缩进的任务）
        elif re.match(r'^\s+\d+\.|^\s+-|^\s+\*|^\s+\[.+\]', line):
            current_subtasks.append(line.strip())
        
        # 检测备注（包含"备注"或"note"的行）
        elif '备注' in line or 'note' in line.lower() or '备注' in line:
            current_notes.append(line)
        
        # 其他文本作为备注
        elif current_task:
            current_notes.append(line)
    
    # 保存最后一个任务
    if current_task:
        tasks.append({
            'title': current_task,
            'subtasks': current_subtasks,
            'notes': current_notes
        })
    
    return tasks

def save_to_markdown(tasks, output_file):
    """保存为Markdown"""
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write('# 滴答清单任务提取\n\n')
        f.write(f'提取时间：{datetime.now().strftime("%Y-%m-%d %H:%M:%S")}\n\n')
        
        for i, task in enumerate(tasks, 1):
            f.write(f'## {i+1}. {task["title"]}\n\n')
            
            # 子任务
            if task.get('subtasks'):
                f.write('### 子任务\n\n')
                for subtask in task['subtasks']:
                    f.write(f'- {subtask}\n')
                f.write('\n')
            
            # 备注
            if task.get('notes'):
                f.write('### 备注\n\n')
                for note in task['notes']:
                    f.write(f'> {note}\n')
                f.write('\n')
        
        f.write(f'---\n')
        f.write(f'**统计**\n')
        f.write(f'- 总任务数：{len(tasks)}\n')
        
        total_subtasks = sum(len(task.get('subtasks', [])) for task in tasks)
        f.write(f'- 总子任务数：{total_subtasks}\n')
        f.write('\n')

if __name__ == '__main__':
    pdf_path = '所有 - 滴答清单.pdf'
    output_file = '滴答清单提取.md'
    
    text = extract_text_from_pdf(pdf_path)
    tasks = parse_tasks(text)
    save_to_markdown(tasks, output_file)
    
    print(f'✅ 提取完成！')
    print(f'任务数：{len(tasks)}')
    print(f'保存到：{output_file}')
