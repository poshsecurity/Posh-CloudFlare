Import-Module -Name .\Posh-CloudFlare.psd1

<#
    Cloud Flare Client Details
#>


$CloudFlareAPIToken     = 'Your Token Here'
$CloudFlareEmailAddress = 'Your Email Here'
$CloudFlareDomain       = 'Your Domain Here'
$CloudFlareURL          = "http://$CloudFlareDomain"
$IPAddress              = '1.1.1.1'


'You can find more information about each command here: https://www.cloudflare.com/docs/client-api.html, section numbers through this refer to section numbers on that page'

'Your CloudFlare Zones - Cloudflare API: 3.2 - "zone_load_multi"'
get-CFDNSZone -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress | Format-Table -Property zone_name

'Show the settings for the specified domain - Cloudflare API: 3.7 "zone_settings"'
get-CFDNSZoneSettings -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain

'CloudFlare states for a domain - CloudFlare API: 3.1 - "stats"'
get-CFDNSZoneStatistics -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain -Period Past30Days

'Get CloudFlare ZIDS - CloudFlare API: 3.4 - "zone_check"'
get-CFDNSZoneStatus -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain

'Get the threat level for a specific ip address - CloudFlare API: 3.6 - "ip_lkup"'
get-CFIPThreatScore -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -IP $IPAddress

'Set the security level for a domain - CloudFlare API: 4.1 - "sec_lvl"'
$CurrentLevel = (get-CFDNSZoneSettings -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain).sec_lvl
"Current Security Level = $CurrentLevel"

'Setting to high'
Set-CFDNSZoneSecurityLevel -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain -Level high

'Getting Security Level'
(get-CFDNSZoneSettings -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain).sec_lvl

'Setting to medium'
Set-CFDNSZoneSecurityLevel -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain -Level med

'Getting Security Level'
(get-CFDNSZoneSettings -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain).sec_lvl

'Setting to low'
Set-CFDNSZoneSecurityLevel -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain -Level low

'Getting Security Level'
(get-CFDNSZoneSettings -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain).sec_lvl

'Setting to Essentially Off'
Set-CFDNSZoneSecurityLevel -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain -Level eoff

'Getting Security Level'
(get-CFDNSZoneSettings -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain).sec_lvl

'Resetting back to original'
Set-CFDNSZoneSecurityLevel -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain -Level $CurrentLevel

'Getting Security Level'
(get-CFDNSZoneSettings -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain).sec_lvl

'Set the Cache Level - CloudFlare API: 4.2 - "cache_lvl"'
$CurrentLevel = (get-CFDNSZoneSettings -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain).cache_lvl
"Current Cache Level = $CurrentLevel"

if ($CurrentLevel -eq 'agg')
{
    'Switch to aggressive'
    Set-CFDNSZoneCacheLevel -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain -Level basic
}
else
{
    'Switch to basic'
    Set-CFDNSZoneCacheLevel -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain -Level agg
}

'Getting Cache Level'
(get-CFDNSZoneSettings -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain).cache_lvl

'Switching back'
Set-CFDNSZoneCacheLevel -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain -Level $CurrentLevel

'Getting Cache Level'
(get-CFDNSZoneSettings -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain).cache_lvl

'Enable Developer Mode (domain wide) - CloudFlare API: 4.3 - "devmode"'
Set-CFDNSZoneDevMode -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain

'Purge CloudFlare Cache - CloudFlare API: 4.4 - "fpurge_ts"'
Clear-CFDNSZoneCache -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain

'Purge a single file in CloudFlare Cache - CloudFlare API: 4.5 - "zone_file_purge"'
Clear-CFDNSZoneFileCache -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain -URL $CloudFlareURL

'BlackList the IP address - CloudFlare API: 4.6 - "wl" / "ban" / "nul"'
Add-CFBlackListIP -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -IP $IPAddress

'WhiteList the IP Address - CloudFlare API: 4.6 - "wl" / "ban" / "nul"'
Add-CFWhiteListIP -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -IP $IPAddress

'Remove the IP Address from the white/blacklists - CloudFlare API: 4.6 - "wl" / "ban" / "nul"'
Remove-CFListIP -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -IP $IPAddress

'Enable IPv6 Support - CloudFlare API: 4.7 - "ipv46"'
Set-CFDNSZoneIPVersion -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain -IPV6

'Enable Rocket Loader - CloudFlare API: 4.8 - "async"'
$CurrentLevel = (get-CFDNSZoneSettings -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain).async
"Current Rocket Loader Level = $CurrentLevel"

'Setting to automatic'
Set-CFDNSZoneRocketLoader -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain -Level automatic

'Getting Rocket Loader Level'
(get-CFDNSZoneSettings -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain).async

'Setting to manual'
Set-CFDNSZoneRocketLoader -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain -Level manual

'Getting Rocket Loader Level'
(get-CFDNSZoneSettings -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain).async

'Setting to off'
Set-CFDNSZoneRocketLoader -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain -Level off

'Getting Rocket Loader Level'
(get-CFDNSZoneSettings -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain).async

'Setting back'
Set-CFDNSZoneRocketLoader -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain -Level $CurrentLevel

'Getting Rocket Loader Level'
(get-CFDNSZoneSettings -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain).async

'Modify Minification Settings - CloudFlare API: 4.9 - "minify"'
'Minification levels:'
'    0 = off'
'    1 = JavaScript only'
'    2 = CSS only'
'    3 = JavaScript and CSS'
'    4 = HTML only'
'    5 = JavaScript and HTML'
'    6 = CSS and HTML'
'    7 = CSS, JavaScript, and HTML '

$CurrentLevel = (get-CFDNSZoneSettings -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain).minify
"Current Minify Level = $CurrentLevel"

'Setting minify to JavaScript and CSS'
Set-CFDNSZoneMinification -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain -JavaScript -CSS

'Getting minification level'
(get-CFDNSZoneSettings -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain).minify

'Setting minify to CSS and HTML'
Set-CFDNSZoneMinification -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain -CSS -HTML

'Getting minification level'
(get-CFDNSZoneSettings -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain).minify

'Reverting back'
Set-CFDNSZoneMinification -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain -MinifyInteger $CurrentLevel

'Getting minification level'
(get-CFDNSZoneSettings -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain).minify

'Enabling Mirage 2 - CloudFlare API: 4.10 - "mirage2"'
$CurrentLevel = (get-CFDNSZoneSettings -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain).mirage2 -eq 1
"Mirage Enabled = $CurrentLevel"

if ($CurrentLevel)
{
    'Disabling'
    Set-CFDNSZoneMirage2 -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain
}
else
{
    'Enabling'
    Set-CFDNSZoneMirage2 -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain -Enable
}

'Getting Mirage Status'
(get-CFDNSZoneSettings -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain).mirage2 -eq 1

'Switching back' 
if ($CurrentLevel)
{
    'Enabling'
    Set-CFDNSZoneMirage2 -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain -Enable
}
else
{
    'Disabling'
    Set-CFDNSZoneMirage2 -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain
}

'Getting Mirage Status'
(get-CFDNSZoneSettings -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain).mirage2 -eq 1

'Getting a Record List - CloudFlare API: 3.3 - "rec_load_all"'
get-CFDNSRecord -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain | Format-Table -Property name, type, content

'Add some records - CloudFlare API: 5.1 - "rec_new"'
New-CFDNSRecord -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain -Name 'arecord.demo' -Content '1.1.1.1' -Type A
New-CFDNSRecord -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain -Name 'cnamerecord.demo' -Content 'poshsecurity.com' -Type CNAME
New-CFDNSRecord -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain -Name 'demo' -Content 'mail.test.local' -Type MX -Priority 10

'Test resolution'
Resolve-DnsName -Name "arecord.demo.$CloudFlareDomain"
Resolve-DnsName -Name "cnamerecord.demo.$CloudFlareDomain"
Resolve-DnsName -Name "demo.$CloudFlareDomain" -Type MX

'Get an updated list'
get-CFDNSRecord -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain | Format-Table -Property name, type, content

'Update a record and enable CloudFlare services - CloudFlare API: 5.2 - "rec_edit"'
Update-CFDNSRecord -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain -EnableCloudFlare -Name 'arecord.demo' -Content '1.1.1.1' -Type A

'Test resolution'
Resolve-DnsName -Name "arecord.demo.$CloudFlareDomain"

'Update the contents of the mx record'
Update-CFDNSRecord -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain -Name 'demo' -Content 'mail2.test.local' -Type MX -Priority 10

'Test resolution'
Resolve-DnsName -Name "demo.$CloudFlareDomain" -Type MX


'Get an updated list'
get-CFDNSRecord -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain | Format-Table -Property name, type, content

'Delete the records - CloudFlare API: 5.3 - "rec_delete"'
Remove-CFDNSRecord -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain -Name 'arecord.demo' -Type A
Remove-CFDNSRecord -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain -Name 'cnamerecord.demo' -Type CNAME
Remove-CFDNSRecord -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain -Name 'demo' -Type MX

'Get an updated list'
get-CFDNSRecord -APIToken $CloudFlareAPIToken -Email $CloudFlareEmailAddress -Zone $CloudFlareDomain | Format-Table -Property name, type, content


'Demo complete'