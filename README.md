# Posh-CloudFlare
PowerShell module for managing CloudFlare domains


The aim of the Posh-CloudFlare module is to simply and automate the management of CloudFlare hosted DNS zones using PowerShell and the CloudFlare Client API.

This module now implements all of the Client API, with 22 CMDLets in total. To simplify things, I have documented what CMDLet maps to what API call below:

CMDLet | API Actions
------------ | -------------
get-CFDNSZoneStatistics     | 3.1 - "stats" - Retrieve domain statistics for a given time frame
get-CFDNSZone               | 3.2 - "zone_load_multi" - Retrieve the list of domains
get-CFDNSRecord             | 3.3 - "rec_load_all" - Retrieve DNS Records of a given domain
get-CFDNSZoneStatus         | 3.4 - "zone_check" - Checks for active zones and returns their corresponding zids
Get-CFIPThreatScore         | 3.6 - "ip_lkup" - Check threat score for a given IP
get-CFDNSZoneSettings       | 3.7 - "zone_settings" - List all current setting values
Set-CFDNSZoneSecurityLevel  | 4.1 - "sec_lvl" - Set the security level
Set-CFDNSZoneCacheLevel     |4.2 - "cache_lvl" - Set the cache level
Set-CFDNSZoneDevMode        |4.3 - "devmode" - Toggling Development Mode
Clear-CFDNSZoneCache        |4.4 - "fpurge_ts" -- Clear CloudFlare's cache
Clear-CFDNSZoneFileCache    |4.5 - "zone_file_purge" -- Purge a single file in CloudFlare's cache
Add-CFBlackListIP           |4.6 - "wl" / "ban" / "nul" -- Whitelist/Blacklist/Unlist IPs
Add-CFWhiteListIP           |4.6 - "wl" / "ban" / "nul" -- Whitelist/Blacklist/Unlist IPs
Remove-CFListIP             |4.6 - "wl" / "ban" / "nul" -- Whitelist/Blacklist/Unlist IPs
Set-CFDNSZoneIPVersion      |4.7 - "ipv46" -- Toggle IPv6 support
Set-CFDNSZoneRocketLoader   |4.8 - "async" -- Set Rocket Loader
Set-CFDNSZoneMinification   |4.9 - "minify" -- Set Minification
Set-CFDNSZoneMirage2        |4.10 - "mirage2" -- Set Mirage2
New-CFDNSRecord             |5.1 - "rec_new" -- Add a DNS record
Update-CFDNSRecord          |5.2 - "rec_edit" -- Edit a DNS record
Remove-CFDNSRecord          |5.3 - "rec_delete" -- Delete a DNS record

The Client API can be a little tricky at first, I have developed the CMDLets in a manner to simplify the learning curve. Typically any API call which modifies or removes a DNS record, would require a rec_id to be specified. This field can be found by querying all of the records in the zone. I have simplified things by performing the search and other API queries for you. You can still specify a rec_id if you like.

Switches and parameter validation sets have been used to simplify some of the other CMDLets, particularly those around minification, security and other zone wide settings.

Finally I have tried where possible to make good use of the Pipeline. There are still a number of areas that could be improved.

##Getting Started

The first thing you will need to do, is obtain your API Token. This can be found on your Account page. You will need this, and the email address you use to sign into CloudFlare for the majority of the CMDLets. For CMDLets which modify DNS Zones or records, you will need to specify the zone as well.

I have included a demo script, Posh-CloudFlare-Demo.ps1 at the root level of the module, which you can run on the namespace of your choice. I recommend not using your corporate production domain. At the top of this script, simply update the API Token, Email and domain name fields as required.

You can then run the script, and see it manipulate the DNS zone. I am not responsible if this breaks production. This script shows you each CMDLet and it's output. I don't recommend simply running the script, I recommend stepping through each line so you gain more of an understanding.

##Potential Uses

The automatic provisionment of cloud hosted environments is why this was developed as well as another project I will announce in the coming future. For now, I see myself working on at least one module to support the automation of Office 365 provisioning, including creating the TXT, MX and SRV required.

##Warnings

Firstly, I haven’t finished up the PowerShell help – Naughty! I will work on this one as I go.

Secondly, there might be some bugs. Whilst I have tried to test the majority of the permutations of the code, I can’t be fully sure I haven’t missed something. If you find one, please feel free to contact me and I will make the required fixes, or even better, push your updates up to GitHub.
