Set-StrictMode -Version 2

function Remove-CFListIP
{
    <# 
        .SYNOPSIS

        .DESCRIPTION

        .PARAMETER APIToken
        This is your API Token from the CloudFlare WebPage (look under user settings).

        .PARAMETER Email
        Your email address you signed up to CloudFlare with.

        .PARAMETER IP
        IP Address to remove from what and black list on all ZONES!

        .INPUTS
        IP addresses can will be accepted from the pipeline

        .OUTPUTS
        System.Management.Automation.PSCustomObject containing the success code returned form the CloudFlare API.

        .EXAMPLE

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
    
        [Parameter(mandatory = $true, valuefrompipeline = $true)]
        [ValidateScript({$_ -match [IPAddress]$_})] 
        [string]
        $IP
    )

    begin
    {
        # Cloudflare API URI
        $CloudFlareAPIURL = 'https://www.cloudflare.com/api_json.html'

        # Build up the request parameters, we need API Token, email, command, dnz zone, dns record type, dns record name and content, and finally the TTL.
        $APIParameters = @{
            'tkn'   = $APIToken
            'email' = $Email
            'a'     = 'nul'
            'key'   = ''
        } 
    }

    Process
    {

        $APIParameters['key'] = $IP

        $JSONResult = Invoke-RestMethod -Uri $CloudFlareAPIURL -Body $APIParameters -Method Get
    
        #if the cloud flare api has returned and is reporting an error, then throw an error up
        if ($JSONResult.result -eq 'error') 
        {throw $($JSONResult.msg)}
    
        $JSONResult.response
    }
}
