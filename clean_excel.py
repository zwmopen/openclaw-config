# Excel去重脚本

import pandas as pd
import hashlib
import sys

def load_excel(file_path):
    """加载Excel文件"""
    try:
        df = pd.read_excel(file_path, engine='openpyxl')
        print(f"✅ 成功加载 {len(df)} 行数据")
        return df
    except Exception as e:
        print(f"❌ 加载失败: {e}")
        return None

def deduplicate_rows(df):
    """删除重复的行"""
    # 计算每行的哈希值
    df['row_hash'] = df.apply(lambda row: hashlib.md5(str(tuple(row)).hexdigest(), axis=1)
    
    # 找出重复行
    duplicates = df[df.duplicated(subset=['row_hash'], keep='first')]
    
    # 删除重复行
    df_cleaned = df.drop_duplicates(subset=['row_hash'], keep='first')
    
    removed_count = len(df) - len(df_cleaned)
    print(f"📊 删除了 {removed_count} 行重复数据")
    
    return df_cleaned, removed_count

def clean_excel(input_file, output_file):
    """清理Excel文件"""
    print(f"开始处理: {input_file}")
    
    # 加载数据
    df = load_excel(input_file)
    if df is None:
        print("❌ 加载失败，退出")
        return
    
    # 去重
    df_cleaned, removed_rows = deduplicate_rows(df)
    
    # 保存清理后的数据
    df_cleaned.to_excel(output_file, index=False, engine='openpyxl')
    
    total_removed = removed_rows
    print(f"✅ 清理完成！")
    print(f"📊 原始行数: {len(df)}")
    print(f"📊 清理后行数: {len(df_cleaned)}")
    print(f"📊 删除重复数据: {total_removed}")
    print(f"💾 保存到: {output_file}")

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("用法: python clean_excel.py <输入文件> <输出文件>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else input_file.replace('.xlsx', '_cleaned.xlsx')
    
    clean_excel(input_file, output_file)
