#!/usr/bin/env python3
"""
Obsidian Skill - Write content to Obsidian vault
"""
import sys
import os
from pathlib import Path
from datetime import datetime

# Default vault path
VAULT_PATH = r"D:\Program Files\Obsidian\zwm\zwm"

def write_file(filepath: str, content: str, mode: str = "w"):
    """Write content to a file in the vault"""
    full_path = Path(VAULT_PATH) / filepath
    full_path.parent.mkdir(parents=True, exist_ok=True)
    
    with open(full_path, mode, encoding="utf-8") as f:
        f.write(content)
    
    return str(full_path)

def main():
    if len(sys.argv) < 3:
        print("Usage: obsidian <action> <filepath> [content]")
        print("Actions: write, append, read")
        sys.exit(1)
    
    action = sys.argv[1]
    filepath = sys.argv[2]
    
    if action == "write":
        if len(sys.argv) < 4:
            print("Error: content required for write action")
            sys.exit(1)
        content = sys.argv[3]
        result = write_file(filepath, content, "w")
        print(f"Written to: {result}")
    
    elif action == "append":
        if len(sys.argv) < 4:
            print("Error: content required for append action")
            sys.exit(1)
        content = "\n" + sys.argv[3]
        result = write_file(filepath, content, "a")
        print(f"Appended to: {result}")
    
    elif action == "read":
        full_path = Path(VAULT_PATH) / filepath
        if full_path.exists():
            with open(full_path, "r", encoding="utf-8") as f:
                print(f.read())
        else:
            print(f"File not found: {filepath}")
            sys.exit(1)
    
    else:
        print(f"Unknown action: {action}")
        sys.exit(1)

if __name__ == "__main__":
    main()
