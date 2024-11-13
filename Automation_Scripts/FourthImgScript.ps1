Write-Host ""
Write-Host "==============================================="
Write-Host "Clearing Panther Folders"
Get-ChildItem -Path "C:\Windows\Panther" -Include *.* -File -Recurse | ForEach-Object {$_.Delete()}
Get-ChildItem -Path "C:\Windows\System32\Sysprep\Panther" -Include *.* -File -Recurse | ForEach-Object {$_.Delete()}

Write-Host ""
Write-Host "==============================================="
Write-Host "Clearing File History"
Get-ChildItem -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths" | ForEach-Object {Remove-Item}
Get-ChildItem -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\WordWheelQuery" | ForEach-Object {Remove-Item}
Get-Process -name *explore* | Kill | Start Explorer.exe

Write-Host ""
Write-Host "==============================================="
Write-Host "Running SysPrep Final"
C:\Windows\System32\Sysprep\Sysprep.exe /generalize /oobe /shutdown