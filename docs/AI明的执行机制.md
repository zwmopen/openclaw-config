# AI明的执行机制

## 1. 不需要打开窗口

我直接在你的电脑后台执行命令，不需要打开窗口，不需要手动输入。

**执行流程**：
```
你发消息 → 我收到 → 我调用 exec 工具 → 直接执行 → 结果返回给我
```

## 2. 可用的工具

| 工具 | 功能 | 示例 |
|------|------|------|
| exec | 执行命令 | Get-Process 检查进程 |
| read | 读文件 | 读取配置文件 |
| write | 写文件 | 创建脚本 |
| edit | 编辑文件 | 修改配置 |
| browser | 浏览器 | 打开网页、截图 |
| web_search | 搜索 | 联网搜索 |
| web_fetch | 抓取网页 | 读取网页内容 |
| sessions_spawn | 启动子代理 | 让 Claude 做事 |
| message | 发消息 | 发送到其他平台 |

## 3. 和 Claude 间接对话

**理论上**，我可以通过 `sessions_spawn` 启动一个 Claude 子代理：

```
我 → sessions_spawn(task="检查电脑") → Claude 子代理 → 执行任务 → 返回结果
```

**但是**，刚才失败了，因为：
```
错误：gateway closed (1008): pairing required
```

**原因**：网关需要配对才能使用子代理功能。

## 4. 我是怎么检查电脑的？

我刚才用的是 `exec` 工具，直接在你的电脑后台执行 PowerShell 命令：

```powershell
# 检查进程
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10

# 检查磁盘
Get-PSDrive -PSProvider FileSystem

# 检查网关
Get-NetTCPConnection -LocalPort 18789

# 检查计划任务
Get-ScheduledTask | Where-Object {$_.TaskName -like "*OpenClaw*"}
```

**结果直接返回给我，我整理成报告发给你。**

## 5. 配对网关

如果想用子代理功能（让 Claude 做事），需要配对网关：

```powershell
# 配对命令
openclaw gateway pair
```

配对后，我就可以：
- 启动 Claude 子代理
- 启动其他模型子代理
- 并行处理多个任务

## 6. 总结

| 功能 | 是否需要配对 |
|------|------------|
| 执行命令（exec）| ❌ 不需要 |
| 读写文件（read/write）| ❌ 不需要 |
| 浏览器（browser）| ❌ 不需要 |
| 搜索（web_search）| ❌ 不需要 |
| 子代理（sessions_spawn）| ✅ 需要配对 |

**目前我不需要配对就能做大部分事情，只是不能用子代理功能。**
