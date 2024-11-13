# Checks that 'C:\ImageSetup' exists
function Test-MainFolder {
    If (Test-Path -Path "C:\ImageSetup") {
        return
    } else {
        Write-Host "The folder 'C:\ImageSetup' does not exist"
        Write-Host "Creating folder 'C:\ImageSetup'"
        New-Item -Path "C:\ImageSetup" -ItemType directory
        return
    }
}

# Checks that 'C:\ImageSetup\Windows 10 New System Setup' exists
function Test-SystemSetup {
    If (Test-Path -Path "C:\ImageSetup\Windows 10 New System Setup") {
        return
    } else {
        Write-Host "The folder 'C:\ImageSetup\Windows 10 New System Setup' does not exist, please create folder"
        Write-Host "This folder can be found in 'NextCloud > ETS Tech Docs > Sysprep"
        Pause
        Test-SystemSetup
    }
}

function Test-Logo {
    If (Test-Path -Path "C:\ImageSetup\Logo.jpg") {
        return
    } else {
        Write-Host "The file 'C:\ImageSetup\Logo.jpg' does not exist, please create file"
        Write-Host "The logo can be found on CDMS or google images. Transparent or white background is required"
        Pause
        Test-Logo
    }
}

# Moves 'copyprofile.xml' & 'install.wim' to 'C:\'
function Move-MyFiles {
    Move-Item -Path "C:\ImageSetup\Windows 10 New System Setup\copyprofile.xml" -Destination "C:\copyprofile.xml"
    Move-Item -Path "C:\ImageSetup\Windows 10 New System Setup\install.wim" -Destination "C:\install.wim"
    Move-Item -Path "C:\ImageSetup\Logo.jpg" -Destination "C:\Windows\Logo.jpg"
}

# Updates any registry values that need to be changed
function Update-Reg {
    # Disable Driver Updates In Win Updates
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows" -Name "WindowsUpdate"
    New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "ExcludeWUDriversInQualityUpdate" -Value 1
    Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\Currentversion\DriverSearching" -Name "SearchOrderConfig" -Value 3
    Write-Host "Drivers through Windows Updates: Disabled"

    # Set Small Icons on desktop
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\Shell\Bags\1\Desktop" -Name "IconSize" -Value 20
    Write-Host "Desktop Icon Size: Small"

    # Remove drop shadow for icons
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewShadow" -Value 0
    Write-Host "Desktop Icon Shadows: Disabled"

    # File Explorer > View Tab:  Uncheck “Hide extensions for known file types.
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0
    Write-Host "Hide File Extensions: Disabled"

    # Set UAC level to lowest
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 5
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop " -Value 0
    Write-Host "UAC: Second Lowest"

    # Point and print restrictions enable
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT" -Name "Printers"
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers" -Name "PointAndPrint"
    New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" -Name "InForest" -Value 0
    New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" -Name "NoWarningNoElevationOnInstall" -Value 1
    New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" -Name "Restricted" -Value 1
    New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" -Name "ServerList"
    New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" -Name "TrustedServers" -Value 0
    New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" -Name "UpdatePromptSettings" -Value 2
    Write-Host "PointAndPrint: Enabled"

    # Disable window 10 welcome animation
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "EnableFirstLogonAnimation" -Value 0
    Write-Host "Windows Welcome Animation: Disabled"

    # Enable L2TP
    New-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\PolicyAgent" -Name "AssumeUDPEncapsulationContextOnSendRule" -Value 2
    New-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\RasMan\Parameters" -Name "ProhibitIpSec" -Value 0 

    Get-Process -name *explore* | Kill | Start Explorer.exe

    # Apply Background Color settings
    Set-ItemProperty 'HKCU:\Control Panel\Colors' -Name "Background" -Value "255 255 255"
}

# Looks for any files with .cab extension, then returns the name of that file
function Get-CabDir {
    begin 
    {
        Set-Location "C:\ImageSetup"
        $myVar = ""
    }
    process
    {
        if (([string](Select-object -InputObject $_ Extension)) -eq "@{Extension=.CAB}") {
            $myVar = $_
        }
    }
    end
    {
        if ($myVar -ne "") {
            return $myVar
        } else {
            Write-Host "The script was unable to locate a '.cab' folder"
            Write-Host "Please place a '.cab' file containing system drivers in 'C:\ImageSetup\'"
            Pause
            Extract-Cab
        }
    }
}

# Extract Cab File
function Extract-Cab {
    $myCab = (Get-ChildItem | Get-CabDir) # Fetches all files in directory, then finds the .cab file
    $cabDir = ".\" + $myCab # appends .\ to the file name of the cab

    New-Item -Path "C:\ImageSetup\CABDriverExtract" -ItemType directory
    Expand.exe $cabDir /f:* .\CABDriverExtract # Extracts cab file
}

# Fixes '.cab' directory
function Fix-Dir {
    process
    {
        [String]$origDir = (Select-Object -InputObject $_ Fullname)
        $fixedDir = $origDir.Substring(11,$origDir.Length-12)
        return $fixedDir
    }
}

function Install-Drivers {
    Set-Location "C:\ImageSetup\CABDriverExtract"

    # Get all file names of files in the driver folder that end with 'inf'
    # passes those file names to Fix-Dir which finds the full directory then fixes the string
    # Iterates through each of the .inf files and tries to install them
    Get-ChildItem -Recurse -Filter *.inf | Fix-Dir | Foreach-Object {Write-Host $_; pnputil.exe /add-driver $_}
}

Write-Host "Verifying Folders/Files"
Test-MainFolder
Test-SystemSetup
Test-Logo
New-Item -Path "C:\Apps" -ItemType directory

Write-Host ""
Write-Host "==============================================="
Write-Host "Moving Files"
Move-MyFiles

Write-Host ""
Write-Host "==============================================="
Write-Host "Updating Registry"
Update-Reg

Write-Host ""
Write-Host "==============================================="
Write-Host "Disabling Sleep & Screen Time Out while plugged in."
powercfg.exe -x -monitor-timeout-ac 0
powercfg.exe -x -standby-timeout-ac 0

Write-Host ""
Write-Host "==============================================="
Write-Host "Extracting & Installing Drivers"
Extract-Cab
Install-Drivers

Write-Host ""
Write-Host "==============================================="
Write-Host "Script has completed, please review transcript for any errors"
Pause