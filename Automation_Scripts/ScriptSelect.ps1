function Select-Script {
    Write-Host "Select Script: 1, 2, 3, 4"
    $global:myScript = Read-Host "Script"
    return 
}

function Select-YN {
    $myQuestion = "Are you sure you want to run script " + $myScript + "? (Y/N)"
    $global:myYN = Read-Host $myQuestion
}

function Run-Logic {
    if ($myYN.ToLower() -eq "y") {
        switch ($myScript) {
            "1" {Invoke-Expression ".\Automation_Scripts\FirstImgScript.ps1"} 
            "2" {Invoke-Expression ".\Automation_Scripts\SecondImgScript.ps1"} 
            "3" {Invoke-Expression ".\Automation_Scripts\ThirdImgScript.ps1"} 
            "4" {Invoke-Expression ".\Automation_Scripts\FourthImgScript.ps1"} 
        }
    } else {
        Write-Host "You either selected NO or your input was invalid, restarting selection process"
        Start-Sleep -Seconds 4
        Clear-Host
        Run-Script
    }
}

function Run-Script {
    Select-Script
    Select-YN
    Run-Logic
}

Start-Transcript -OutputDirectory "C:\ImageSetup\AutoWinImg\Transcripts\"
Run-Script
