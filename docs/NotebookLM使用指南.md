# NotebookLM使用指南

## 什么是NotebookLM？

Google的AI笔记本，可以上传文档让AI帮你分析、总结、生成内容。

## 安装状态

✅ 已安装：notebooklm-py 0.3.3
⏸️ 待登录：需要Google账号授权

## 配置步骤

### 1. 登录Google账号（必须）

打开PowerShell，运行：
```powershell
notebooklm login
```

会自动打开浏览器，用Google账号授权。

### 2. 验证登录

```powershell
notebooklm status
```

应该显示你的Google邮箱。

### 3. 列出现有笔记本

```powershell
notebooklm list
```

## 常用命令

### 创建笔记本

```powershell
notebooklm create "笔记标题"
```

### 添加资料

```powershell
# 添加网页
notebooklm source add "https://example.com"

# 添加YouTube视频
notebooklm source add "https://youtube.com/watch?v=xxx"

# 添加PDF文件
notebooklm source add "./file.pdf"

# 添加图片
notebooklm source add "./image.png"

# 添加音频
notebooklm source add "./audio.mp3"

# 添加视频
notebooklm source add "./video.mp4"
```

### 与内容对话

```powershell
notebooklm ask "总结一下这篇文章的核心观点"
```

### 生成播客（Audio Overview）

```powershell
# 生成播客
notebooklm generate audio "关注重点内容"

# 等待生成完成（10-20分钟）
notebooklm artifact list

# 下载播客
notebooklm download audio ./podcast.mp3
```

### 生成视频

```powershell
# 生成视频
notebooklm generate video "解释这个概念"

# 等待生成完成（15-45分钟）
notebooklm artifact list

# 下载视频
notebooklm download video ./video.mp4
```

### 生成其他内容

```powershell
# 生成测验题
notebooklm generate quiz

# 生成学习卡片
notebooklm generate flashcards

# 生成思维导图
notebooklm generate mind-map

# 生成报告
notebooklm generate report --format study-guide

# 生成幻灯片
notebooklm generate slide-deck
```

## 使用场景

### 代运营系统

1. 上传客户资料 → 生成内容策略
2. 上传爆款笔记 → 学习写作风格
3. 上传行业报告 → 生成选题建议

### 内容生产系统

1. 上传历史爆款 → 提取成功模式
2. 上传行业热点 → 生成选题库
3. 上传用户反馈 → 分析需求趋势

### 学习笔记

1. 上传课程资料 → 生成学习笔记
2. 上传论文 → 提取核心观点
3. 上传书籍 → 生成思维导图

## 明哥2.0的使用建议

### 第一步：创建"明哥2.0内容生产系统"笔记本

```powershell
notebooklm create "明哥2.0内容生产系统"
```

### 第二步：上传素材

```powershell
# 上传爆款笔记
notebooklm source add "D:\Program Files\Obsidian\zwm\.zwm\02-ZWM 2.0 内容生产系统\01-内容生产\03-内容素材库\"

# 上传行业报告
notebooklm source add "行业报告.pdf"

# 上传客户资料
notebooklm source add "客户资料.pdf"
```

### 第三步：生成内容

```powershell
# 生成选题建议
notebooklm ask "根据这些素材，给我推荐10个选题"

# 生成内容策略
notebooklm ask "分析这些爆款笔记的共同特点，总结内容策略"

# 生成播客（用于学习）
notebooklm generate audio "总结内容生产的核心方法"
```

## 语言设置

```powershell
# 设置为中文
notebooklm language set zh_Hans

# 查看当前语言
notebooklm language get
```

## 注意事项

1. **需要翻墙**：NotebookLM是Google服务，需要科学上网
2. **生成时间长**：播客10-20分钟，视频15-45分钟
3. **有配额限制**：每天生成的数量有限
4. **支持格式**：PDF、YouTube、网页、图片、音频、视频

## 更多帮助

```powershell
notebooklm --help
notebooklm generate --help
notebooklm source --help
```
