function Invoke-APRestMethod
{
    <#
    .SYNOPSIS

    Invokes Azure DevOps Pipelines rest method.

    .DESCRIPTION

    Invokes Azure DevOps Pipelines rest method.

    .PARAMETER Method
    
    Specifies the method used for the web request.

    .PARAMETER Body
    
    Specifies the body of the request. The body is the content of the request that follows the headers.

    .PARAMETER ContentType
    
    Specifies the content type of the web request. If this parameter is omitted and the request method is POST, Invoke-RestMethod sets the content type to application/x-www-form-urlencoded. Otherwise, the content type is not specified in the call.

    .PARAMETER Uri

    Specifies the Uniform Resource Identifier (URI) of the Internet resource to which the web request is sent. This parameter supports HTTP, HTTPS, FTP, and FILE values.

    .PARAMETER UseBasicParsing

    This parameter has been deprecated. Beginning with PowerShell 6.0.0, all Web requests use basic parsing only. 

    .PARAMETER Credential

    Specifies a user account that has permission to send the request. The default is the Personal Access Token if it is defined, otherwise it is the current user.
    
    .OUTPUTS

    System.Int64, System.String, System.Xml.XmlDocument, The output of the cmdlet depends upon the format of the content that is retrieved.

    .OUTPUTS

    PSObject, If the request returns JSON strings, Invoke-RestMethod returns a PSObject that represents the strings.

    .EXAMPLE

    C:\PS> Invoke-APRestMethod -Method PATCH -Body $Body -ContentType 'application/json' -Uri 'https://myproject.visualstudio.com/release/releases?api-version=5.0-preview.6'

    .LINK

    https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-restmethod?view=powershell-6
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]
        $Method,

        [Parameter()]
        [psobject]
        $Body,

        [Parameter(Mandatory)]
        [uri]
        $Uri,

        [Parameter()]
        [string]
        $ContentType,

        [Parameter()]
        [switch]
        $UseBasicParsing,

        [Parameter()]
        [pscredential]
        $Credential
    )

    begin
    {
    }
    
    process
    {
        $invokeRestMethodSplat = @{
            ContentType     = $ContentType
            Method          = $Method
            UseBasicParsing = $true
            Uri             = $uri.AbsoluteUri
        }
        If($Body)
        {
            $invokeRestMethodSplat.Body = $Body | ConvertTo-Json -Depth 20 
        }
        $authenticatedRestMethodSplat = Set-APAuthenticationType -InputObject $invokeRestMethodSplat -Credential $Credential
        $results = Invoke-RestMethod @authenticatedRestMethodSplat
        Return $results
    }
    
    end
    {
    }
}
