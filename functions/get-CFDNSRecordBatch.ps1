Set-StrictMode -Version 2

function get-CFDNSRecordBatch
{
    <# 
        .SYNOPSIS
        This is a helper CMDLet to support the Get-CFDNSRecordBatch. This is not exposed to users

        .DESCRIPTION
        Returns a list (with additional informaiton) of the DNS records hosted in CloudFlare for the specified domain name. This will return the JSON directly from the CloudFlare API, and *may not* be all of the records. 
        Check the has_more and offset to determine if there are more records. You must specify your API Token and your Email addresses along with the Zone (full qualified).

        .PARAMETER APIToken
        This is your API Token from the CloudFlare WebPage (look under user settings).

        .PARAMETER Email
        Your email address you signed up to CloudFlare with.

        .PARAMETER Zone
        The zone you want to add this new record to. For example, poshsecurity.com.

        .PARAMETER Offset
        Where in the records list do you want to start (see cloudflare API doco)

        .INPUTS
        This takes no input from the pipeline

        .OUTPUTS
        System.Management.Automation.PSCustomObject containing the record information returned form the CloudFlare API.

        .EXAMPLE
        Get-CFDNSRecord -APIToken '<My Token>' -Email 'user@domain.com' -Zone 'domain.com'
        Returns all records in the specified zone, unless has_more is true

        .EXAMPLE
        Get-CFDNSRecord -APIToken '<My Token>' -Email 'user@domain.com' -Zone 'domain.com' -offset 100
        Returns all records in the specified zone, starting at the 100 record

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
        [ValidateScript({
                    $_.contains('@')
                }
        )]
        [string]
        $Email,

        [Parameter(mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Zone,

        [Parameter(mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [int]$Offset
    )

    # Cloudflare API URI
    $CloudFlareAPIURL = 'https://www.cloudflare.com/api_json.html'

    # Build up the request parameters, we need API Token, email, command, dnz zone, dns record type, dns record name and content, and finally the TTL.
    $APIParameters = New-Object  -TypeName System.Collections.Specialized.NameValueCollection
    $APIParameters.Add('tkn', $APIToken)
    $APIParameters.Add('email', $Email)
    $APIParameters.Add('a', 'rec_load_all')
    $APIParameters.Add('z', $Zone)
    $APIParameters.Add('o', $Offset)

    # Create the webclient and set encoding to UTF8
    $webclient = New-Object  -TypeName Net.WebClient
    $webclient.Encoding = [System.Text.Encoding]::UTF8

    # Post the API command
    $WebRequest = $webclient.UploadValues($CloudFlareAPIURL, 'POST', $APIParameters)

    #convert the result from UTF8 and then convert from JSON
    $JSONResult = ConvertFrom-Json -InputObject ([System.Text.Encoding]::UTF8.GetString($WebRequest))
    
    #if the cloud flare api has returned and is reporting an error, then throw an error up
    if ($JSONResult.result -eq 'error') 
    {
        throw $($JSONResult.msg)
    }
    
    $JSONResult
    #    #return [System.Text.Encoding]::UTF8.GetString($result) -replace 'content":"[a-zA-Z0-9\+\\\/]+",', 'content":"removed",' | ConvertFrom-Json
    #    $JSONResult -replace 'content":"[a-zA-Z0-9\+\\\/]+",', 'content":"removed",'
}
