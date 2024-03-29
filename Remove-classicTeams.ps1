<#
.SYNOPSIS
This script uninstalls the Teams app and removes the Teams directory for a user.
.DESCRIPTION
Use this script to remove and clear the Teams app from a computer. Run this PowerShell script for each user profile in which Teams was installed on the computer. After you run this script for all user profiles, redeploy Teams.

.NOTES
File Name      : Remove-classicTeams.ps1
Author         : 0x3321c@github
Version        : 1.0.0

.ROLE
Standard User

.FUNCTIONALITY
Script ensures teams uninstallation

.LINK
https://learn.microsoft.com/en-us/microsoftteams/scripts/powershell-script-deployment-cleanup

#>

$TeamsPath = [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Microsoft', 'Teams')
$TeamsUpdateExePath = [System.IO.Path]::Combine($TeamsPath, 'Update*.exe')



#Get environment variables
$userTempFolder = "$env:TEMP"
$computerName = $env:COMPUTERNAME

#Set Debugging 
$debugFile = "$userTempFolder\$computerName-Teams.log"

#Set Timing
$datestamp = Get-Date -Format 'yyyy-MM-dd'


function Write-Log {
    param (
        [string]$message,
        [string]$type = "Info",
        [string]$LogFilePath = "$userTempFolder\$computerName-Teams.log"
    )
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logEntry = "$timestamp [$type] - $message"
    Add-Content -Path $LogFilePath -Value $logEntry
}

try {
    Write-Log "### Remove-Classic-Teams-Logging ###"

    if (Test-Path $TeamsUpdateExePath) {
        Write-Log "Uninstalling Teams process"
        
        # Uninstall app
        $proc = Start-Process $TeamsUpdateExePath "-uninstall -s" -PassThru -ErrorAction Stop
        $proc.WaitForExit()

        Write-Log "Teams process uninstallation complete"
    } else {
        Write-Log "Teams Update.exe not found. Skipping uninstallation."
    }

    if (Test-Path $TeamsPath) {
        Write-Log "Deleting Teams directory"
        Remove-Item -Path $TeamsPath -Recurse -ErrorAction Stop
        Write-Log "Teams directory deletion complete"
    } else {
        Write-Log "Teams directory not found. Skipping deletion."
    }

    Write-Log "Teams uninstallation process completed successfully"
}
catch {
    $errorMessage = "Uninstall failed with exception: $($_.Exception.Message)"
    Write-Log $errorMessage -type "Error"
    throw $errorMessage
}
