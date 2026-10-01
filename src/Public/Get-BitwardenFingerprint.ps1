function Get-BitwardenFingerprint
{
    [cmdletbinding()]
    Param(
        # User Id
        [Parameter(Mandatory = $false, HelpMessage = "The unique identifier of the user whose fingerprint phrase you want to retrieve")]
        [ValidateScript({
                $_ -is [guid] -or ($_ -is [string] -and -not [string]::IsNullOrWhiteSpace($_))
            })]
        $UserId,

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
        $requestUri = "$([System.Uri]::UriSchemeHttp)$([System.Uri]::SchemeDelimiter)$($Hostname.Trim()):$($Port)"

        if ($MyInvocation.BoundParameters.ContainsKey("UserId"))
        {
            $id = $null

            if ($UserId -is [guid])
            {
                $id = $UserId.Guid
            }
            else
            {
                $id = $UserId
            }

            $requestUri = "$($requestUri)/object/fingerprint/$($id)"
        }
        else
        {
            $requestUri = "$($requestUri)/object/fingerprint/me"
        }

        Write-Verbose "RequestUri : $requestUri"
    }

    PROCESS
    {
        $webRequestSplatParameters = @{
            Method          = "Get";
            Uri             = $requestUri;
            UseBasicParsing = $true
        }

        try
        {
            $webRequestResult = Invoke-WebRequest @webRequestSplatParameters -ErrorAction Stop
        }
        catch
        {
            throw "An exception occurred while retrieving the user fingerprint : $($_.Exception.Message)"
        }

        $jsonWebRequestContent = $webRequestResult.Content | ConvertFrom-Json

        return $jsonWebRequestContent.data.data
    }

    END
    {
    }
}