@echo off
chcp 65001 >nul 2>&1
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -Command "Start-Process powershell -ArgumentList '-ExecutionPolicy Bypass -Command \"schtasks /create /tn OpenClaw-GitHub-Backup /tr ''powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File D:\\AI编程\\openclaw\\scripts\\auto-backup-github.ps1 -Quiet'' /sc daily /st 22:00 /rl HIGHEST /f\"' -Verb RunAs"
