# OpenClaw Gateway 启动脚本使用指南

## 问题根源

**命令窗口闪现的原因**：
1. `OpenClaw-Scan` 任务每1分钟执行一次，路径错误，缺少 `-WindowStyle Hidden`
2. `OpenClaw_OpenADrive` 任务缺少 `-WindowStyle Hidden`
3. 素材库迁移后，定时任务路径未更新

## 已解决的问题

### 1. 删除废弃任务 ✅
- **OpenClaw-Scan**：每1分钟执行的废弃任务，已删除

### 2. 修复定时任务 ✅
- **OpenClaw_OpenADrive**：重新创建，添加 `-WindowStyle Hidden`

### 3. 清理旧脚本 ✅
删除了15个重复功能的脚本：
- check-gateway-health.ps1
- Check-OpenClawGateway.ps1
- create-startup-task.ps1
- gateway-monitor.ps1
- keepalive-gateway-fixed.ps1
- keepalive-gateway.ps1
- restart-gateway-safe.ps1
- restart-gateway.ps1
- restart-reminder.ps1
- start-claudian-proxy.ps1
- start-gateway-hidden.ps1
- start-gateway-now.ps1
- start-gateway-simple.ps1
- start-gateway.ps1
- startup-sequence.ps1

### 4. 创建新脚本 ✅
- **启动Gateway.bat** - 启动脚本（窗口停留显示状态）
- **重启Gateway.bat** - 重启脚本（窗口停留显示状态）
- **检查状态.bat** - 状态检查（窗口停留显示状态）

### 5. 创建桌面快捷方式 ✅
- 启动Gateway.lnk
- 重启Gateway.lnk
- 检查状态.lnk

### 6. 更新开机自启动 ✅
- 更新 `Startup\OpenClaw-Gateway.lnk` 指向新脚本

## 新脚本特点

### 启动Gateway.bat
- ✅ 显示窗口，实时显示启动过程
- ✅ 显示端口、PID、内存等状态信息
- ✅ 健康检查，确保 Gateway 正常运行
- ✅ 窗口停留11分钟（或按任意键关闭）
- ✅ 如果 Gateway 已在运行，显示状态并退出

### 重启Gateway.bat
- ✅ 自动停止所有 Gateway 进程
- ✅ 检查端口是否释放
- ✅ 启动新的 Gateway 进程
- ✅ 显示详细的启动日志
- ✅ 窗口停留11分钟（或按任意键关闭）

### 检查状态.bat
- ✅ 显示 Gateway 运行状态
- ✅ 显示端口、PID、内存信息
- ✅ 健康检查
- ✅ 窗口停留11分钟（或按任意键关闭）

## 使用方法

### 双击桌面快捷方式
- **启动Gateway.lnk** - 启动 Gateway
- **重启Gateway.lnk** - 重启 Gateway
- **检查状态.lnk** - 检查状态

### 开机自启动
- 已配置开机自动启动
- 启动脚本会在后台运行，不会弹窗

### 如果需要管理员权限
双击 `fix-scheduled-tasks.bat`，会自动以管理员权限运行修复脚本。

## 以后避免类似问题

**创建定时任务时，务必：**
1. 使用 `-WindowStyle Hidden` 参数
2. 文件路径变更时，同步更新定时任务
3. 任务完成后，及时禁用或删除
4. 定期检查定时任务，确保没有异常

**标准创建流程：**
```powershell
# 1. 创建任务（必须带 -WindowStyle Hidden）
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File '脚本路径'"

# 2. 创建触发器
$trigger = New-ScheduledTaskTrigger -Daily -At 8:00AM

# 3. 创建设置
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopOnIdleEnd -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

# 4. 创建主体（使用最高权限）
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest

# 5. 注册任务
Register-ScheduledTask -TaskName "任务名称" -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description "任务描述"
```

## 记忆

这次教训已记录到 SOUL.md，以后创建定时任务时会自动检查是否包含 `-WindowStyle Hidden`。
