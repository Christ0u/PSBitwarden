function Lock-BitwardenVault
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
        $requestUri = "$([System.Uri]::UriSchemeHttp)$([System.Uri]::SchemeDelimiter)$($Hostname.Trim()):$($Port)/lock"
    }

    PROCESS
    {
        $webRequestSplatParameters = @{
            Method          = "Post";
            Uri             = $requestUri;
            UseBasicParsing = $true
        }

        try
        {
            Invoke-WebRequest @webRequestSplatParameters -ErrorAction Stop | Out-Null
        }
        catch
        {
            throw "An exception occurred while unlocking the vault : $($_.Exception.Message)"
        }

        Write-Information -MessageData "Your vault is locked." -InformationAction Continue
    }

    END
    {
    }
}