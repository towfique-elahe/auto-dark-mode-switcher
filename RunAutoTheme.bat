@echo off
:: Launch PowerShell GUI without console window
powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0AutoThemeGUI.ps1"
