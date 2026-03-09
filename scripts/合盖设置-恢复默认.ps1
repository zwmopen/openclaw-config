# 合盖设置 - 恢复默认（合盖睡眠）
# 用途：让笔记本合盖后进入睡眠状态

Write-Host "=== 恢复合盖默认设置 ===" -ForegroundColor Cyan
Write-Host ""

# 设置合盖操作
# 1 = 睡眠

Write-Host "设置合盖操作为：睡眠" -ForegroundColor Yellow

# AC电源设置
powercfg /SETACVALUEINDEX SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e590c477fb1 5ca83367-6e45-459f-a27b-476b1d01c936 1
Write-Host "  ✅ AC电源：合盖进入睡眠" -ForegroundColor Green

# DC电池设置
powercfg /SETDCVALUEINDEX SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e590c477fb1 5ca83367-6e45-459f-a27b-476b1d01c936 1
Write-Host "  ✅ DC电池：合盖进入睡眠" -ForegroundColor Green

# 激活电源计划
powercfg /SETACTIVE SCHEME_CURRENT

Write-Host ""
Write-Host "=== 设置完成 ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "合盖后笔记本会："
Write-Host "  • 进入睡眠状态"
Write-Host "  • 节省电量"
Write-Host "  • 需要按电源键唤醒"
