Write-Host "Removing Pre-installed Apps"
Get-AppxPackage -AllUsers | Remove-AppxPackage

Write-Host ""
Write-Host "==============================================="
Write-Host "Cleaning System"
cleanmg.exe /VERYLOWDISK

Get-ChildItem -Path  'C:\ImageSetup' -Recurse | Select-Object -ExpandProperty FullName | Where-Object {$_ -notlike 'C:\ImageSetup\AutoWinImg*'} | Sort-Object length -Descending | Remove-Item -force 
Remove-Item "C:\copyprofile.xml"
Remove-Item "C:\install.wim"

Write-Host "All Administrative Setup Files have been removed."

pause
