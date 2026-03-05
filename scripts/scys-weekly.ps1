# 生财有术周报抓取脚本
# 每周六上午 9:00 自动执行

$ErrorActionPreference = "Stop"

# 配置
$SavePath = "D:\Program Files\Obsidian\zwm\.zwm\生财有术日报"
$LogFile = "$SavePath\抓取日志.txt"

# 日志函数
function Write-Log {
    param($Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] $Message"
    Write-Host $LogMessage -ForegroundColor Cyan
    Add-Content -Path $LogFile -Value $LogMessage
}

Write-Log "开始抓取生财有术周报..."

# 检查目录是否存在
if (-not (Test-Path $SavePath)) {
    New-Item -ItemType Directory -Path $SavePath -Force | Out-Null
    Write-Log "创建目录: $SavePath"
}

# 获取当前周数
$Today = Get-Date
$WeekOfYear = [System.Globalization.CultureInfo]::CurrentCulture.Calendar.GetWeekOfYear($Today, [System.Globalization.CalendarWeekRule]::FirstDay, [System.DayOfWeek]::Monday)
$Year = $Today.Year
$WeekFolder = "$SavePath\周报\$Year-W$WeekOfYear"

if (-not (Test-Path $WeekFolder)) {
    New-Item -ItemType Directory -Path $WeekFolder -Force | Out-Null
    Write-Log "创建周报目录: $WeekFolder"
}

# TODO: 在这里添加浏览器自动化抓取逻辑
# 1. 打开生财有术网站
# 2. 登录（使用保存的登录状态）
# 3. 点击"文章点赞榜" -> "近7天"
# 4. 滚动读取所有文章
# 5. 点击每篇文章，读取详细内容
# 6. 按标题查重
# 7. 保存为 Markdown 文件

Write-Log "抓取完成！"

# 推送到飞书
$Date = Get-Date -Format "yyyy-MM-dd"
$Message = @"
## 📰 生财有术周报 - $Date

> 由 OpenClaw 自动抓取推送

抓取完成！请查看：
$WeekFolder

**抓取时间**：$Timestamp
**抓取内容**：文章点赞榜 - 近7天
"@

# TODO: 使用 message 工具推送到飞书
Write-Log "推送通知到飞书..."
