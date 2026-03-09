# 合盖不关机设置脚本
# 用途：让笔记本合盖后主机继续运行，OpenClaw保持在线

Write-Host "=== 合盖设置脚本 ===" -ForegroundColor Cyan
Write-Host ""

# 显示当前设置
Write-Host "当前合盖操作设置：" -ForegroundColor Yellow
$currentAC = powercfg /QUERY SCHEME_CURRENT SUB_BUTTONS LIDACTION_AC 2>&1 | Select-String "当前 AC 电源设置"
$currentDC = powercfg /QUERY SCHEME_CURRENT SUB_BUTTONS LIDACTION_DC 2>&1 | Select-String "当前 DC 电源设置"
Write-Host "  AC（接通电源）：$currentAC"
Write-Host "  DC（使用电池）：$currentDC"
Write-Host ""

# 设置合盖操作
# 0 = 不采取任何操作
# 1 = 睡眠
# 2 = 休眠
# 3 = 关机

Write-Host "设置合盖操作为：不采取任何操作" -ForegroundColor Green

# AC电源设置
powercfg /SETACVALUEINDEX SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e590c477fb1 5ca83367-6e45-459f-a27b-476b1d01c936 0
Write-Host "  ✅ AC电源：合盖不采取任何操作" -ForegroundColor Green

# DC电池设置
powercfg /SETDCVALUEINDEX SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e590c477fb1 5ca83367-6e45-459f-a27b-476b1d01c936 0
Write-Host "  ✅ DC电池：合盖不采取任何操作" -ForegroundColor Green

# 激活电源计划
powercfg /SETACTIVE SCHEME_CURRENT

Write-Host ""
Write-Host "=== 设置完成 ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "合盖后笔记本会：" -ForegroundColor Yellow
Write-Host "  • 关闭屏幕（省电）"
Write-Host "  • 主机继续运行"
Write-Host "  • OpenClaw保持在线"
Write-Host "  • 定时任务正常执行"
Write-Host "  • 心跳检查继续工作"
Write-Host ""
Write-Host "如需恢复默认设置（合盖睡眠），请运行：" -ForegroundColor Yellow
Write-Host "  .\合盖设置-恢复默认.ps1"
