# Claude 代理技能

> 通过触发词调用 Claude Code 处理复杂任务

## 触发词

| 关键词 | 动作 |
|--------|------|
| `给Claude说:` | 调用 Claude Code 处理任务 |
| `问Claude:` | 调用 Claude Code 回答问题 |
| `Claude帮我:` | 调用 Claude Code 执行操作 |

---

## 使用方式

```
用户：给Claude说: 帮我重构这个函数
→ 我启动 Claude Code 执行任务

用户：问Claude: 这个错误怎么解决？
→ 我启动 Claude Code 分析问题

用户：Claude帮我: 写一个Python脚本处理CSV
→ 我启动 Claude Code 编写代码
```

---

## 执行流程

1. **识别触发词**
   - 检测到 `给Claude说:` / `问Claude:` / `Claude帮我:`
   - 提取后面的任务描述

2. **启动 Claude Code**
   ```bash
   # 后台运行，PTY模式
   exec pty:true workdir:{工作目录} background:true command:"claude '{任务描述}'"
   ```

3. **监控进度**
   - 用 `process action:log` 查看输出
   - 完成后返回结果

4. **返回结果**
   - 简要总结 Claude 完成了什么
   - 如果有问题，转达给用户

---

## 工作目录选择

| 任务类型 | 工作目录 |
|----------|----------|
| 通用任务 | `D:\AI编程\openclaw\` |
| 笔记整理 | `D:\Program Files\Obsidian\zwm\.zwm\` |
| 项目开发 | 根据用户指定 |

---

## 参数说明

- `pty:true` - 必须！Claude Code 需要终端
- `background:true` - 后台运行，不阻塞
- `workdir` - 工作目录，限制 Claude 的访问范围

---

## 注意事项

1. **简单任务不调用** - 能直接处理的就不麻烦 Claude
2. **保持简洁** - 不要在 Claude 运行时频繁汇报
3. **等待完成** - Claude 处理需要时间，不要急于打断
4. **转达问题** - 如果 Claude 有疑问，及时转达给用户

---

## Claude Code 能做什么

- ✅ 文件操作（读写、创建、删除）
- ✅ 代码编写和重构
- ✅ 命令执行
- ✅ Git 操作
- ✅ 项目分析
- ✅ 错误调试
- ✅ 复杂任务自动化

---

## 示例

### 示例1：代码重构
```
用户：给Claude说: 重构 openclaw/skills/timeboxing/SKILL.md，让它更简洁

我：好的，让 Claude 来处理...
[启动 Claude Code，等待完成]
完成！Claude 重构了 SKILL.md，主要改动：
- 简化了时间盒子流程
- 添加了快速示例
```

### 示例2：项目分析
```
用户：问Claude: 这个项目的架构是什么？

我：让 Claude 分析一下...
[启动 Claude Code，等待完成]
Claude 分析结果：
- 主项目是 OpenClaw
- 核心模块：Gateway、消息路由、技能系统
- 技能目录：skills/
- 配置文件：openclaw.json
```

### 示例3：批量操作
```
用户：Claude帮我: 把所有技能文件名改成中文

我：这个任务比较复杂，让 Claude 来处理...
[启动 Claude Code，等待完成]
完成！Claude 重命名了以下文件：
- timeboxing → 时间盒子
- weather → 天气
- ...
```
