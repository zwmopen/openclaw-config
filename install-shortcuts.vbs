Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

' 获取脚本所在目录
scriptPath = WScript.ScriptFullName
scriptDir = fso.GetParentFolderName(scriptPath)

' 创建桌面快捷方式
desktopPath = WshShell.SpecialFolders("Desktop")
shortcutPath = desktopPath & "\OpenClaw.lnk"

Set shortcut = WshShell.CreateShortcut(shortcutPath)
shortcut.TargetPath = "powershell.exe"
shortcut.Arguments = "-ExecutionPolicy Bypass -File """ & scriptDir & "\start-all.ps1"""
shortcut.WorkingDirectory = scriptDir
shortcut.Description = "OpenClaw 一键启动"
shortcut.IconLocation = "C:\Users\z\.trae-cn\binaries\node\versions\22.18.0\node_modules\openclaw\assets\icon.ico"
shortcut.Save

WScript.Echo "桌面快捷方式已创建: " & shortcutPath

' 创建开机自启动快捷方式
startupPath = WshShell.SpecialFolders("Startup")
startupShortcutPath = startupPath & "\OpenClaw-Gateway.lnk"

Set startupShortcut = WshShell.CreateShortcut(startupShortcutPath)
startupShortcut.TargetPath = "powershell.exe"
startupShortcut.Arguments = "-ExecutionPolicy Bypass -WindowStyle Hidden -File """ & scriptDir & "\start-gateway-silent.ps1"""
startupShortcut.WorkingDirectory = scriptDir
startupShortcut.Description = "OpenClaw 网关开机自启动"
startupShortcut.Save

WScript.Echo "开机自启动已创建: " & startupShortcutPath
WScript.Echo ""
WScript.Echo "完成！OpenClaw 现在会开机自动启动网关。"
