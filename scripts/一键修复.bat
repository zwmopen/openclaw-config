@echo off
cd /d "%~dp0"
powershell.exe -ExecutionPolicy Bypass -Command "Start-Process powershell.exe -ArgumentList '-ExecutionPolicy Bypass -File \"%~dpn0.ps1\"' -Verb RunAs"
