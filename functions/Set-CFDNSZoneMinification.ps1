Set-StrictMode -Version 2

function Set-CFDNSZoneMinification
{
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
        [ValidateNotNullOrEmpty()]
        [string]
        $Email,

        [Parameter(mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Zone,

        [Parameter(mandatory = $false)]
        [switch]
        $JavaScript,

        [Parameter(mandatory = $false)]
        [switch]
        $CSS,

        [Parameter(mandatory = $false)]
        [switch]
        $HTML,

        [Parameter(mandatory = $false)]
        [ValidateRange(0,7)]
        [int]
        $MinifyInteger

    )

    # Cloudflare API URI
    $CloudFlareAPIURL = 'https://www.cloudflare.com/api_json.html'

    # Build up the request parameters
    $APIParameters = @{
        'tkn'   = $APIToken
        'email' = $Email
        'a'     = 'minify'
        'z'     = $Zone
    }

    if ($MinifyInteger -ne $null)
    {
        $minify = 0

        if ($JavaScript)
        {$minify = $minify + 1} 

        if ($CSS)
        {$minify = $minify + 2} 

        if ($HTML)
        {$minify = $minify + 4} 
    
        $APIParameters.Add('v', $minify)
    }
    else
    {$APIParameters.Add('v', $MinifyInteger)}

    $JSONResult = Invoke-RestMethod -Uri $CloudFlareAPIURL -Body $APIParameters -Method Get
    
    #if the cloud flare api has returned and is reporting an error, then throw an error up
    if ($JSONResult.result -eq 'error') 
    {throw $($JSONResult.msg)}
    
    $JSONResult.result
}
