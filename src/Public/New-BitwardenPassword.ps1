function New-BitwardenPassword
{
    [cmdletbinding()]
    Param(
        # Password length
        [Parameter(Mandatory = $false, HelpMessage = "Number of characters in the password.")]
        [ValidateRange(1, 128)]
        [int]
        $Length = 14,

        # Password should contains lowercase characters
        [Parameter(Mandatory = $false, HelpMessage = "Include lowercase characters in the password.")]
        [switch]
        $IncludeLowercaseCharacters,

        # Password should contains uppercase characters
        [Parameter(Mandatory = $false, HelpMessage = "Include uppercase characters in the password.")]
        [switch]
        $IncludeUppercaseCharacteres,

        # Password should contains numeric characters
        [Parameter(Mandatory = $false, HelpMessage = "Include numeric characters in the password.")]
        [switch]
        $IncludeNumericCharacters,

        # Password should contains special characters
        [Parameter(Mandatory = $false, HelpMessage = "Include special characters in the password.")]
        [switch]
        $IncludeSpecialCharacters,

        # Exclude ambiguous characters
        [Parameter(Mandatory = $false, HelpMessage = "Exclude ambiguous characters in the password.")]
        [switch]
        $ExcludeAmbiguousCharacters,

        # Minimum numeric characters the password should contains
        [Parameter(Mandatory = $false, HelpMessage = "Minimum number of numeric characters to include in the password.")]
        [ValidateRange(0, 9)]
        [int]
        $MinimumNumericCharacters = 0,

        # Minimum special characters the password should contains
        [Parameter(Mandatory = $false, HelpMessage = "Minimum number of special characters to include in the password.")]
        $MinimumSpecialCharacters = 0,

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
        $requestUri = "$([System.Uri]::UriSchemeHttp)$([System.Uri]::SchemeDelimiter)$($Hostname.Trim()):$($Port)/generate?length=$($Length)&lowercase=$($IncludeLowercaseCharacters)&uppercase=$($IncludeUppercaseCharacteres)&number=$($IncludeNumericCharacters)&special=$($IncludeSpecialCharacters)&ambiguous=$($ExcludeAmbiguousCharacters)"

        if ($MyInvocation.BoundParameters.ContainsKey("MinimumNumericCharacters"))
        {
            # Prise en compte du paramètre IncludeNumericCharacters seulement s'il est associé au paramètre IncludeNumericCharacters
            if ($IncludeNumericCharacters -or
                (
                    -not $MyInvocation.BoundParameters.ContainsKey("IncludeLowercaseCharacters") -and
                    -not $MyInvocation.BoundParameters.ContainsKey("IncludeUppercaseCharacteres") -and
                    -not $MyInvocation.BoundParameters.ContainsKey("IncludeSpecialCharacters")
                )
            )
            {
                $requestUri = "$($requestUri)&minNumber=$($MinimumNumericCharacters)"
            }
            else
            {
                Write-Warning "The value of the 'MinimumNumericCharacters' parameter was ignored because you enabled at least one other character set without enabling 'IncludeNumericCharacters'."

                $requestUri = "$($requestUri)&minNumber=0"
            }
        }
        else
        {
            $requestUri = "$($requestUri)&minNumber=0"
        }

        if ($MyInvocation.BoundParameters.ContainsKey("MinimumSpecialCharacters"))
        {
            if ($IncludeSpecialCharacters -or
                (
                    -not $MyInvocation.BoundParameters.ContainsKey("IncludeLowercaseCharacters") -and
                    -not $MyInvocation.BoundParameters.ContainsKey("IncludeUppercaseCharacteres") -and
                    -not $MyInvocation.BoundParameters.ContainsKey("IncludeNumericCharacters")
                )
            )
            {
                $requestUri = "$($requestUri)&minSpecial=$($MinimumSpecialCharacters)"
            }
            else
            {
                Write-Warning "The value of the 'MinimumSpecialCharacters' parameter was ignored because you enabled at least one other character set without enabling 'IncludeSpecialCharacters'."

                $requestUri = "$($requestUri)&minSpecial=0"
            }
        }
        else
        {
            $requestUri = "$($requestUri)&minSpecial=0"
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
            throw "An exception occurred while generating a password : $($_.Exception.Message)"
        }

        $jsonWebRequestContent = $webRequestResult.Content | ConvertFrom-Json

        return $jsonWebRequestContent.data.data
    }

    END
    {
    }
}