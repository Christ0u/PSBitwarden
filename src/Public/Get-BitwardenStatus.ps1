function Get-BitwardenStatus
{
    [cmdletbinding()]
    Param(
        # Hostname
        [Parameter(Mandatory = $false, HelpMessage = "The hostname to bind your API webserver to. The default hostname is 'localhost'")]
        [ValidateScript({
                -not [string]::IsNullOrWhiteSpace($_)
            })]
        [string]
        $Hostname = "localhost",

        # Port
        [Parameter(Mandatory = $false, HelpMessage = "The port to run your API webserver on. The default port is '8087'")]
        [ValidateScript({
                $_ -is [int] -and $_ -ge 0 -and $_ -le 65535
            })]
        $Port = 8087
    )

    BEGIN
    {
        $requestUri = "$([System.Uri]::UriSchemeHttp)$([System.Uri]::SchemeDelimiter)$($Hostname.Trim()):$($Port)/status"
        Write-Verbose "RequestUri : $requestUri"
    }

    PROCESS
    {
        try
        {
            $webRequestResult = Invoke-WebRequest -Method Get -Uri $requestUri -UseBasicParsing -ErrorAction Stop
        }
        catch
        {
            throw "An exception occurred while retrieving the vault status : $($_.Exception.Message)"
        }

        $jsonWebRequestContent = $webRequestResult.Content | ConvertFrom-Json

        return $jsonWebRequestContent.data.template
    }

    END
    {
    }
}
