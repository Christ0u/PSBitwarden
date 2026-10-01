function Sync-BitwardenVault
{
    [cmdletbinding()]
    Param(
        # Full sync
        [Parameter(Mandatory = $false, HelpMessage = "Force a full sync from the server, ignoring the last-sync timestamp")]
        [switch]
        $FullSync,

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
        $requestUri = "$([System.Uri]::UriSchemeHttp)$([System.Uri]::SchemeDelimiter)$($Hostname.Trim()):$($Port)/sync"

        if ($MyInvocation.BoundParameters.ContainsKey("FullSync"))
        {
            $requestUri += "?force=true"
        }
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
            $webRequestResult = Invoke-WebRequest @webRequestSplatParameters -ErrorAction Stop
        }
        catch
        {
            throw "An exception occurred while syncing the vault : $($_.Exception.Message)"
        }

        Write-Information -MessageData "Syncing complete." -InformationAction Continue
    }

    END
    {
    }
}