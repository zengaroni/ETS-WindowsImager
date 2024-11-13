$ProgressPreference = "SilentlyContinue"

$adobeURL = "https://ardownload2.adobe.com/pub/adobe/reader/win/AcrobatDC/2200120142/AcroRdrDC2200120142_en_US.exe"
$adobeOut = "C:\Apps\AcroRdrDC2200120142_en_US.exe"
Write-Host "Starting Adobe Download"
Invoke-WebRequest -Uri $adobeURL -OutFile $adobeOut
Write-Host "Starting Adobe Install"
Start-Process -FilePath $adobeOut -ArgumentList "/spb /rs /rps /msi /norestart /quiet EULA_ACCEPT=YES" -Wait
Write-Host "Adobe is installed"

$chromeURL = "https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7B912E70E9-68FB-7912-F20E-4C62DB66E613%7D%26lang%3Den%26browser%3D4%26usagestats%3D1%26appname%3DGoogle%2520Chrome%26needsadmin%3Dtrue%26ap%3Dx64-stable-statsdef_0%26brand%3DGCEA/dl/chrome/install/googlechromestandaloneenterprise64.msi"
$chromeOut = "C:\Apps\Chrome_Setup.Msi"
Write-Host "Starting Chrome Download"
Invoke-WebRequest -Uri $chromeURL -OutFile $chromeOut
Write-Host "Starting Chrome Install"
Start-Process -FilePath C:\Windows\System32\msiexec.exe -ArgumentList "/i $chromeOut /passive" -Wait
Write-Host "Chrome is installed"

Write-Host ""
Write-Host "==============================================="
Write-Host "Deleting Adobe & Chrome Installers"
Remove-Item -Path $adobeOut
Remove-Item -Path $chromeOut

Write-Host ""
Write-Host "==============================================="
Write-Host "Clearing Icons on Desktop"
Get-ChildItem -Path "C:\Users\Public\Desktop" -Include *.* -File -Recurse | ForEach-Object {$_.Delete()}
Get-ChildItem -Path "C:\Users\Administrator\Desktop" -Include *.* -File -Recurse | ForEach-Object {$_.Delete()}

Write-Host ""
Write-Host "==============================================="
Write-Host "Changing Desktop Wallpaper"
New-Item -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies' -Name 'System'
New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'Wallpaper' -Value 'C:\Windows\Logo.jpg'
New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'WallpaperStyle' -Value '0'

# Tries to go through and delete file history
Write-Host ""
Write-Host "==============================================="
Write-Host "Deleting File History"
try {
    Get-ChildItem -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths" | ForEach-Object {Remove-Item}
}
catch [System.Management.Automation.ItemNotFoundException] {
    Write-Host "No 'TypedPaths' to delete"
}
try {
    Get-ChildItem -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\WordWheelQuery" | ForEach-Object {Remove-Item}
}
catch [System.Management.Automation.ItemNotFoundException] {
    Write-Host "No 'WordWheelQuery' to delete"
}
try {
    Get-ChildItem -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" | ForEach-Object {Remove-Item}
}
catch [System.Management.Automation.ItemNotFoundException] {
    Write-Host "No 'RunMRU' to delete"
}
try {
    Get-ChildItem -Path "C:\Users\Administrator\AppData\Microsoft\Windows\Recent\AutomaticDestinations" | ForEach-Object {Remove-Item}
}
catch [System.Management.Automation.ItemNotFoundException] {
    Write-Host "No 'AutomaticDestination' to delete"
}
try {
    Get-ChildItem -Path "C:\Users\Administrator\AppData\Microsoft\Windows\Recent\CustomDestinations" | ForEach-Object {Remove-Item}
}
catch [System.Management.Automation.ItemNotFoundException] {
    Write-Host "No 'CustomerDestinations' to delete"
}
try {
    Get-ChildItem -Path "C:\Users\Administrator\AppData\Microsoft\Windows\Recent" | ForEach-Object {Remove-Item}
}
catch [System.Management.Automation.ItemNotFoundException] {
    Write-Host "No 'Recent' to delete"
}

Get-Process -name *explore* | Stop-Process | Start-Process Explorer.exe

Clear-Host
Write-Host "==============================================="
Write-Host "The script is about half way done"
Write-Host "This is the time to:"
Write-Host " - Install any additional apps"
Write-Host " - Copy any post-installation scripts to 'C:\apps'"
Write-Host " - Set Chrome Startup to 'www.google.com'"
Pause

Write-Host ""
Write-Host "==============================================="
Write-Host "Reseting Apps to Default Settings"
try 
{
    Get-AppxPackage *windows.immersivecontrolpanel* | Reset-AppxPackage
}
catch [System.Management.Automation.CommandNotFoundException] 
{
    Get-AppxPackage -allusers | ForEach-Object 
        {
            try {
                Add-AppxPackage -register "$($_.InstallLocation)\appxmanifest.xml" -DisableDevelopmentMode
            }
            catch [System.Exception]{
                continue
            }
        }
}

Write-Host""
Write-Host "==============================================="
Write-Host "Clearing Chrome Browser History & Cookies"
Start-Sleep -Seconds 4

try {
    Remove-Item -Path "C:\Users\Administrator\AppData\Local\Google\Chrome\User Data\Default\History"
}
catch [System.Management.Automation.ItemNotFoundException] {
    Write-Host "No 'History' to delete"
}
try {
    Remove-Item -Path "C:\Users\Administrator\AppData\Local\Google\Chrome\User Data\Default\History-journal"

}
catch [System.Management.Automation.ItemNotFoundException] {
    Write-Host "No 'History-journal' to delete"
}
try {
    Remove-Item -Path "C:\Users\Administrator\AppData\Local\Google\Chrome\User Data\Default\Network\Cookies"
}
catch [System.Management.Automation.ItemNotFoundException] {
    Write-Host "No 'Cookies' to delete"
}
try {
    Remove-Item -Path "C:\Users\Administrator\AppData\Local\Google\Chrome\User Data\Default\Network\Cookies-journal"
}
catch [System.Management.Automation.ItemNotFoundException] {
    Write-Host "No 'Cookies-journal' to delete"
}

Write-Host""
Write-Host "==============================================="
Write-Host "Creating Network Share Folders on Desktop"
Move-Item -Path "C:\ImageSetup\Windows 10 New System Setup\Apps_2021\Tools\Profile Icons\Applications.lnk" -Destination "C:\Users\Administrator\Desktop\Applications.lnk"
Move-Item -Path "C:\ImageSetup\Windows 10 New System Setup\Apps_2021\Tools\Profile Icons\Teacher Public Folder.lnk" -Destination "C:\Users\Administrator\Desktop\Public Folder.lnk"
Move-Item -Path "C:\ImageSetup\Windows 10 New System Setup\Apps_2021\Tools\Profile Icons\User's Network Folder.lnk" -Destination "C:\Users\Administrator\Desktop\User's Network Folder.lnk"

Write-Host ""
Write-Host "==============================================="
Write-Host "Changing Time Zone to MST"
Set-TimeZone -Id "Mountain Standard Time"
net start w32time
W32tm /resync /force

Pause
