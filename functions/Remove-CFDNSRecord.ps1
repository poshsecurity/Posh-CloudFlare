Set-StrictMode -Version 2

Function Remove-CFDNSRecord
{
    <# 
        .SYNOPSIS
        Removes a DNS zone entry from a CloudFlare managed DNS Zone

        .DESCRIPTION
        Removes the record which is specified by ID which can be obtained from Get-CloudFlareRecord or by the name and type of  the entry.

        .PARAMETER APIToken
        This is your API Token from the CloudFlare WebPage (look under user settings).

        .PARAMETER Email
        Your email address you signed up to CloudFlare with.

        .PARAMETER Zone
        The zone you want to add this new record to. For example, poshsecurity.com.

        .PARAMETER ID
        This is the record ID (rec_id) that cloudflare has associated with the entry

        .PARAMETER NAME
        This is the name of the entry, eg for test.domain.com, then the name is 'test'. In JSON responses, this is actually display_name. You can enter '@' for the root of the domain. Wildcards not supported (yet).

        .PARAMETER TYPE
        What type of record? Almost everything is supported here, including: A, CNAME, MX, TXT, SPF, AAAA, NS, SRV, LOC. Added to provide some extra protection.

        .INPUTS
        This takes no input from the pipeline

        .OUTPUTS
        System.Management.Automation.PSCustomObject containing the record information returned form the CloudFlare API.

        .EXAMPLE 
        Remove-CFDNSRecord -APIToken $tkn -Email user@domain.com -Zone domain.com -ID 193737628
        This would remove the entry with id 193737628 from the zone

        .EXAMPLE 
        Remove-CFDNSRecord -APIToken $tkn -Email user@domain.com -Zone domain.com -Name 'test' -Type A -Verbose
        This would remove test.domain.com A record from the zone.

        .NOTES
        NAME: 
        AUTHOR: Kieran Jacobsen - Posh Security - http://poshsecurity.com
        LASTEDIT: 1/1/2015
        KEYWORDS: DNS, CloudFlare, Posh Security

        .LINK
        http://poshsecurity.com

        .LINK 
        http://https://github.com/poshsecurity/Posh-CloudFlare

    #>

    [OutputType([PSCustomObject])]
    [CMDLetBinding()]
    param
    (
        [Parameter(mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $APIToken,

        [Parameter(mandatory = $true)]
        [ValidatePattern("[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")]
        [string]
        $Email,

        [Parameter(mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Zone,

        [Parameter(mandatory = $true, ParameterSetName = 'FindByID')]
        [ValidateNotNullOrEmpty()]
        [string]
        $ID,

        [Parameter(mandatory = $true,ParameterSetName = 'FindByName')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(mandatory = $true,ParameterSetName = 'FindByName')]
        [ValidateSet('A', 'CNAME', 'MX', 'TXT', 'SPF', 'AAAA', 'NS', 'SRV', 'LOC')]
        [string]
        $Type
    )
    # Cloudflare API URI
    $CloudFlareAPIURL = 'https://www.cloudflare.com/api_json.html'

    # Build up the request parameters, we need API Token, email, command, dnz zone, and the record id to delete
    $APIParameters = @{
        'tkn'   = $APIToken
        'email' = $Email
        'a'     = 'rec_delete'
        'z'     = $Zone
    }

    if ($ID -ne '') 
    {
        Write-Verbose -Message 'Deletion by ID'
        $APIParameters.Add('id', $ID)
        
        $JSONResult = Invoke-RestMethod -Uri $CloudFlareAPIURL -Body $APIParameters -Method Get
    
        #if the cloud flare api has returned and is reporting an error, then throw an error up
        if ($JSONResult.result -eq 'error') 
        {throw $($JSONResult.msg)}

        $JSONResult.result
    }
    else
    {
        Write-Verbose -Message 'Deletion by Name and Type'
        $APIParameters.Add('id', '0')
        
        if ($Name -eq '@')
        {$Name -eq $Zone}
        
        $Record = Get-CFDNSRecord -APIToken $APIToken -Email $Email -Zone $Zone | Where-Object -FilterScript { ($_.display_name -eq $Name) -and ($_.type -eq $Type)}
        if ($Record -eq $null)
        {throw 'No record found'}
        
        foreach ($Rec in $Record)
        {
            $APIParameters['id'] = $Rec.rec_id
            $JSONResult = Invoke-RestMethod -Uri $CloudFlareAPIURL -Body $APIParameters -Method Get
    
            #if the cloud flare api has returned and is reporting an error, then throw an error up
            if ($JSONResult.result -eq 'error') 
            {throw $($JSONResult.msg)}

            $JSONResult.result
        }    
    }
}
