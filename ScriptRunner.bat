PowerShell -Command "Set-ExecutionPolicy UnRestricted -Force"
cd /D "%~dp0"
PowerShell -File ".\Automation_Scripts\ScriptSelect.ps1"
PowerShell -Command "Set-ExecutionPolicy Restricted -Force"
pause