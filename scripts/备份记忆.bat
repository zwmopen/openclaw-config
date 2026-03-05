@echo off
chcp 65001 >nul
title OpenClaw 记忆备份
PowerShell -NoProfile -ExecutionPolicy Bypass -File "%~dp0backup-memory.ps1"
pause
