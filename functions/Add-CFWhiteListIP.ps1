Set-StrictMode -Version 2

function Add-CFWhiteListIP
{
    <# 
        .SYNOPSIS

        .DESCRIPTION

        .PARAMETER APIToken
        This is your API Token from the CloudFlare WebPage (look under user settings).

        .PARAMETER Email
        Your email address you signed up to CloudFlare with.

        .PARAMETER IP
        IP Address to whitelist list on all ZONES!

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
        [ValidateScript({
                    $_.contains('@')
                }
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $Email,
    
        [Parameter(mandatory = $true,
                   valuefrompipeline = $true
        )]
        [ValidateScript({
                    $_ -match [IPAddress]$_ 
                }
        )] 
        [string]
        $IP
    )

    begin
    {
        # Cloudflare API URI
        $CloudFlareAPIURL = 'https://www.cloudflare.com/api_json.html'

        # Build up the request parameters
        $APIParameters = New-Object  -TypeName System.Collections.Specialized.NameValueCollection
        $APIParameters.Add('tkn', $APIToken)
        $APIParameters.Add('email', $Email)
        $APIParameters.Add('a', 'wl')
        $APIParameters.Add('key', '') 

        # Create the webclient and set encoding to UTF8
        $webclient = New-Object  -TypeName Net.WebClient
        $webclient.Encoding = [System.Text.Encoding]::UTF8
    }

    Process
    {

        $APIParameters['key'] = $IP

        # Post the API command
        $WebRequest = $webclient.UploadValues($CloudFlareAPIURL, 'POST', $APIParameters)

        #convert the result from UTF8 and then convert from JSON
        $JSONResult = ConvertFrom-Json -InputObject ([System.Text.Encoding]::UTF8.GetString($WebRequest))
    
        #if the cloud flare api has returned and is reporting an error, then throw an error up
        if ($JSONResult.result -eq 'error') 
        {
            throw $($JSONResult.msg)
        }
    
        $JSONResult.response
    }
}
