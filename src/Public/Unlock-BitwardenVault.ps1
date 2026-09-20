function Unlock-BitwardenVault
{
    [cmdletbinding()]
    Param(
        # Master password
        [Parameter(Mandatory = $true, HelpMessage = "Bitwarden vault's master password")]
        [securestring]
        $MasterPassword,

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
        $requestUri = "$([System.Uri]::UriSchemeHttp)$([System.Uri]::SchemeDelimiter)$($Hostname.Trim()):$($Port)/unlock"

        $password = [System.Net.NetworkCredential]::new([string]::Empty, $MasterPassword).Password

        $requestBody = "{`"password`":`"$($password)`"}"
    }

    PROCESS
    {
        $webRequestSplatParameters = @{
            Method          = "Post";
            Uri             = $requestUri;
            Body            = $requestBody;
            ContentType     = "application/json";
            UseBasicParsing = $true
        }

        try
        {
            $webRequestResult = Invoke-WebRequest @webRequestSplatParameters -ErrorAction Stop
        }
        catch
        {
            throw "An exception occurred while unlocking the vault : $($_.Exception.Message)"
        }

        Write-Information -MessageData "Your vault is unlocked." -InformationAction Continue

        $jsonWebRequestContent = $webRequestResult.Content | ConvertFrom-Json

        # Clear sensitive values from memory
        $password = $null
        $requestBody = $null

        return $jsonWebRequestContent.data.raw
    }

    END
    {
    }
}