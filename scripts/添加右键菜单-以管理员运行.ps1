# 添加PowerShell脚本右键菜单"以管理员身份运行"
# 需要以管理员身份运行此脚本

Write-Host "添加PowerShell脚本右键菜单..." -ForegroundColor Cyan

# 添加右键菜单
$regPath = "Registry::HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\Shell\runas"

# 创建注册表项
New-Item -Path $regPath -Force | Out-Null
Set-ItemProperty -Path $regPath -Name "(Default)" -Value "以管理员身份运行"
Set-ItemProperty -Path $regPath -Name "Icon" -Value "powershell.exe"

# 创建command子项
New-Item -Path "$regPath\Command" -Force | Out-Null
Set-ItemProperty -Path "$regPath\Command" -Name "(Default)" -Value "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -Command `"Start-Process powershell -ArgumentList '-ExecutionPolicy Bypass -File `"%1`"' -Verb RunAs`""

Write-Host "完成！现在右键PowerShell脚本可以看到'以管理员身份运行'选项" -ForegroundColor Green
