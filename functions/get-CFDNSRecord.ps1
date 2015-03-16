Set-StrictMode -Version 2

function get-CFDNSRecord
{
    <# 
        .SYNOPSIS
        Returns all DNS Records hosted in CloudFlare for a specified domain

        .DESCRIPTION
        Returns a list (with additional informaiton) of all the DNS records hosted in CloudFlare for the specified domain name. You must specify your API Token and your Email addresses along with the Zone (full qualified).

        .PARAMETER APIToken
        This is your API Token from the CloudFlare WebPage (look under user settings).

        .PARAMETER Email
        Your email address you signed up to CloudFlare with.

        .PARAMETER Zone
        The zone you want to add this new record to. For example, poshsecurity.com.

        .INPUTS
        This takes no input from the pipeline

        .OUTPUTS
        System.Management.Automation.PSCustomObject containing the record information returned form the CloudFlare API.

        .EXAMPLE
        Get-CFDNSRecord -APIToken '<My Token>' -Email 'user@domain.com' -Zone 'domain.com'
        Returns all records in the specified zone

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
        $Zone
    )
    
    #we start off at offset 0 (beggining of the list of dns entries)
    $Offset = 0
    
    #record set starts empty
    $records = $null
    
    #we asumme there will be records to begin with
    $hasmore = $true
    
    #while the API returns
    while ($hasmore) 
    {      
        #Query for the first batch of records
        $results = get-CFDNSRecordBatch -APIToken $APIToken -Email $Email -Zone $Zone -Offset $Offset

        #add the records returned to our collection
        $records = $records + $results.response.recs.objs

        #Increment our offset by the number of records returned by the API
        $Offset = $results.response.recs.count

        #Do we have any more results (if this errors, we don't)
        try 
        {$hasmore = $results.response.recs.has_more} 
        catch 
        {$hasmore = $false}

        Write-Verbose  -Message "There are more records $hasmore, offset is $Offset"
    }

    #return the JSON based record set
    $records
}
