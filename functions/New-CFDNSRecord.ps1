Set-StrictMode -Version 2

function New-CFDNSRecord 
{
    <# 
        .SYNOPSIS
        Creates specificed DNS entry in CloudFlare.

        .DESCRIPTION
        Creates the specified DNS Record within the specified DNS Zone that is hosted within CloudFlare's infrastructure. You must specify your API Token and your Email addresses along with the Zone (full qualified).

        .PARAMETER APIToken
        This is your API Token from the CloudFlare WebPage (look under user settings).

        .PARAMETER Email
        Your email address you signed up to CloudFlare with.

        .PARAMETER Zone
        The zone you want to add this new record to. For example, poshsecurity.com.

        .PARAMETER Name
        The record you want to add. For example, www.poshsecurity.com. Use '@' to specify the root of the domain.

        .PARAMETER Content
        The content for the record, this would be an IP address for an A record, or another hostname for a CNAME, or Text for a TXT record. For MX or SRV this is your "target"

        .PARAMETER Type
        What type of record? Almost everything is supported here, including: A, CNAME, MX, TXT, SPF, AAAA, NS, SRV, LOC

        .PARAMETER TTL
        Time to live for this DNS record, defaults to 1 which is automatic.

        .PARAMETER Priority
        Required for MX and SRV records.

        .PARAMETER Service
        Required for SRV records. An example of a Service would be _sip.

        .PARAMETER Protocol
        Required for SRV records. Valid options are _tcp, _udp and _tls

        .PARAMETER Weight
        Required for SRV records. Weighting of the record.

        .PARAMETER Port
        Required for SRV records. Service port number.

        .INPUTS
        This takes no input from the pipeline

        .OUTPUTS
        System.Management.Automation.PSCustomObject containing the record information returned form the CloudFlare API.

        .EXAMPLE
        New-CFDNSRecord -APIToken '<My Token> -Email 'user@domain.com' -Zone 'domain.com' -Name 'www' -Content '123.123.123.123' -Type A
        Creates A record pointing www.domain.com to the ip address 123.123.123.123

        .EXAMPLE
        New-CFDNSRecord -APIToken '<My Token> -Email 'user@domain.com' -Zone 'domain.com' -Name 'mail' -Content 'mailserver.domain.com' -Type CNAME
        Creates a CNAME record directing mail.domain.com to mailserver.domain.com

        .EXAMPLE
        New-CFDNSRecord -APIToken '<My Token> -Email 'user@domain.com' -Zone 'domain.com' -Name '@' -Content 'mailserver.domain.com' -Type MX -Priority 10
        Creates a MX record definine mailserver.domain.com as a mail server for domain.com

        .EXAMPLE
        New-CFDNSRecord -APIToken '<My Token> -Email 'user@domain.com' -Zone 'domain.com' -Name '@' -Content 'sipdir.online.lync.com' -Type SRV -Priority 100 -Service '_sip' -Protocol _tls -Weight 1 -Port 443 -Verbose
        Creates a SRV record, this is a typical Office365 example. The full address created is _sip._tls.domain.com which points to sipdir.online.lync.com, with priority 100 and weight 1. This specifies protocol is tls and port is 443.

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
    [CMDLetBinding(DefaultParameterSetName = 'Default')]
    param
    (       
        [Parameter(mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [ValidateNotNullOrEmpty()]
        [string]
        $APIToken,

        [Parameter(mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [ValidatePattern("[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")]
        [string]
        $Email,

        [Parameter(mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Zone,

        [Parameter(mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [Alias('Target')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Content,

        [Parameter(mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [ValidateSet('A', 'CNAME', 'MX', 'TXT', 'SPF', 'AAAA', 'NS', 'SRV', 'LOC')]
        [string]
        $Type,
    
        [Parameter(mandatory = $False, ValueFromPipelineByPropertyName = $True)]
        [ValidateScript({($_ -eq 1) -or (($_ -ge 120) -and ($_ -le 86400))})]
        [ValidateNotNullOrEmpty()]
        [int]
        $TTL = 1,
        

        [Parameter(mandatory = $True, ValueFromPipelineByPropertyName = $True, ParameterSetName = 'SRV')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Service,

        [Parameter(mandatory = $True, ValueFromPipelineByPropertyName = $True, ParameterSetName = 'SRV')]
        [ValidateSet('_tcp', '_udp', '_tls')]
        [string]
        $Protocol,

        [Parameter(mandatory = $True, ValueFromPipelineByPropertyName = $True, ParameterSetName = 'SRV')]
        [Parameter(mandatory = $True, ValueFromPipelineByPropertyName = $True, ParameterSetName = 'MX')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Priority,
        
        [Parameter(mandatory = $True, ValueFromPipelineByPropertyName = $True, ParameterSetName = 'SRV')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Weight,

        [Parameter(mandatory = $True, ValueFromPipelineByPropertyName = $True, ParameterSetName = 'SRV')]
        [ValidateRange(1, [UInt16]::MaxValue)]
        [UInt16]$Port

    )
    
    Begin
    {
        # Cloudflare API URI
        $CloudFlareAPIURL = 'https://www.cloudflare.com/api_json.html'
    }

    Process
    {
        # Build up the request parameters, we need API Token, email, command, dnz zone, dns record type, dns record name and content, and finally the TTL.
        $APIParameters = @{
            'tkn'     = $APIToken
            'email'   = $Email
            'a'       = 'rec_new'
            'z'       = $Zone
            'type'    = $Type
            'name'    = $Name
            'content' = $Content
            'ttl'     = $TTL
        }

    
        if (($Type -eq 'SRV') -or ($Type -eq 'MX'))
        {
            Write-Verbose -Message 'Adding Priority'
            $APIParameters.Add('prio', $Priority)
        }

        if ($Type -eq 'SRV')
        {
            Write-Verbose -Message 'Adding SRV specifics'
            $APIParameters.Add('service', $Service)
            $APIParameters.Add('srvname', $Name)
            $APIParameters.Add('protocol', $Protocol)
            $APIParameters.Add('weight', $Weight)
            $APIParameters.Add('port', $Port)
            $APIParameters.Add('target', $Content)
        }

        $JSONResult = Invoke-RestMethod -Uri $CloudFlareAPIURL -Body $APIParameters -Method Get
    
        #if the cloud flare api has returned and is reporting an error, then throw an error up
        if ($JSONResult.result -eq 'error') 
        {throw $($JSONResult.msg)}

        #return the record object from JSON response
        $JSONResult.response.rec.obj
    }
}
