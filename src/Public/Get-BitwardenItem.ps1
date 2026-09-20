function Get-BitwardenItem
{
    [cmdletbinding(DefaultParameterSetName = "GetItemByFilter")]
    Param(
        # Parameter help description
        [Parameter(Mandatory = $true, ParameterSetName = "GetItemById", HelpMessage = "Unique identifier of the item to retrieve")]
        [ValidateScript({
                $_ -is [guid] -or ($_ -is [string] -and -not [string]::IsNullOrWhiteSpace($_))
            })]
        $Id,

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

        if ($PSCmdlet.ParameterSetName -eq "GetItemById")
        {
            if ($Id -is [guid])
            {
                $itemId = $Id.Guid
            }
            else
            {
                $itemId = $Id
            }

            $requestUri = "$($requestUri)/object/item/$($itemId)"
        }
        else
        {
            $requestUri = "$($requestUri)/list/object/items"
        }
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
            throw "An exception occurred while retrieving the vault item : $($_.Exception.Message)"
        }

        $jsonWebRequestContent = $webRequestResult.Content | ConvertFrom-Json

        return $jsonWebRequestContent
    }

    END
    {
    }
}