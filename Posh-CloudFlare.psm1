#
# Export the module members - KUDOS to the chocolatey project for this efficent code
# 


#get the path of where the module is saved (if module is at c:\myscripts\module.psm1, then c:\myscripts\)
$mypath = (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)

#find all the ps1 files in the subfolder functions
Resolve-Path -Path $mypath\functions\*.ps1 | ForEach-Object -Process {
    . $_.ProviderPath
}

#export as module members the functions we specify
Export-ModuleMember -Function New-CFDNSRecord, Get-CFDNSRecord, Remove-CFDNSRecord, Get-CFDNSZone, get-CFDNSZoneStatus, get-CFIPThreatScore, get-CFDNSZoneSettings, Set-CFDNSZoneSecurityLevel, Set-CFDNSZoneCacheLevel, Set-CFDNSZoneDevMode, Clear-CFDNSZoneCache, Clear-CFDNSZoneFileCache, Add-CFWhiteListIP, Add-CFBlackListIP, Remove-CFListIP, Set-CFDNSZoneIPVersion, Set-CFDNSZoneRocketLoader, Set-CFDNSZoneMinification, Set-CFDNSZoneMirage2, Update-CFDNSRecord, get-CFDNSZoneStatistics

#
# Define any alias and export them - Kieran Jacobsen
#
