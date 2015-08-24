Set-StrictMode -Version 2

function get-CFDNSZoneStatistics
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
        [string]
        $Email,

        [Parameter(mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Zone,

        [Parameter(mandatory = $true)]
        [ValidateSet('Past30Days', 'Past7Days', 'PastDay', 'Past24Hours', 'Past12Hours', 'Past6hours')]
        [string]
        $Period
    )

    # Cloudflare API URI
    $CloudFlareAPIURL = 'https://www.cloudflare.com/api_json.html'

    # Build up the request parameters
    $APIParameters = @{
        'tkn'   = $APIToken
        'email' = $Email
        'a'     = 'stats'
        'z'     = $Zone
    }

    $interval = 20

    switch ($Period)
    {
        'Past30Days' 
        {$interval = 20}
        'Past7Days'  
        {$interval = 30}
        'PastDay'    
        {$interval = 40}
        'Past24Hours' 
        {$interval = 100}
        'Past12Hours' 
        {$interval = 110}
        'Past6hours'  
        {$interval = 120}
    }

    $APIParameters.Add('interval', $interval)

    $JSONResult = Invoke-RestMethod -Uri $CloudFlareAPIURL -Body $APIParameters -Method Get
    
    #if the cloud flare api has returned and is reporting an error, then throw an error up
    if ($JSONResult.result -eq 'error') 
    {throw $($JSONResult.msg)}
    
    $JSONResult.response.result
}
