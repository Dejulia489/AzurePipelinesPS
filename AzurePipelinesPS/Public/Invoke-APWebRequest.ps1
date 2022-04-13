function Invoke-APWebRequest
{
    <#
    .SYNOPSIS

    Invokes an Azure Pipelines PS rest method.

    .DESCRIPTION

    Invokes an Azure Pipelines PS rest method.

    .PARAMETER Method
    
    Specifies the method used for the web request.

    .PARAMETER Body
    
    Specifies the body of the request. The body is the content of the request that follows the headers.

    .PARAMETER ContentType
    
    Specifies the content type of the web request. If this parameter is omitted and the request method is POST, Invoke-RestMethod sets the content type to application/x-www-form-urlencoded. Otherwise, the content type is not specified in the call.

    .PARAMETER Uri

    Specifies the Uniform Resource Identifier (URI) of the Internet resource to which the web request is sent. This parameter supports HTTP, HTTPS, FTP, and FILE values.

    .PARAMETER PersonalAccessToken

    Personal access token used to authenticate that has been converted to a secure string. 
    It is recomended to uses an Azure Pipelines PS session to pass the personal access token parameter among funcitons, See New-APSession.
    https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=vsts
    
    .PARAMETER Credential

    Specifies a user account that has permission to send the request. The default is the Personal Access Token if it is defined, otherwise it is the current user.

    .PARAMETER Proxy
    
    Use a proxy server for the request, rather than connecting directly to the Internet resource. Enter the URI of a network proxy server.

    .PARAMETER ProxyCredential
    
    Specifie a user account that has permission to use the proxy server that is specified by the -Proxy parameter. The default is the current user.

    .PARAMETER Path

    The directory to output files to.
    
    .OUTPUTS

    System.Int64, System.String, System.Xml.XmlDocument, The output of the cmdlet depends upon the format of the content that is retrieved.

    .OUTPUTS

    PSObject, If the request returns JSON strings, Invoke-RestMethod returns a PSObject that represents the strings.

    .EXAMPLE

    Invokes AP rest method 'PATCH' against the uri 'https://dev.azure.com/release/releases?api-version=5.0-preview.6'.

    Invoke-APWebRequest -Method PATCH -Body $Body -ContentType 'application/json' -Uri 'https://dev.azure.com/release/releases?api-version=5.0-preview.6'

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
        [object]
        $Body,

        [Parameter(Mandatory)]
        [uri]
        $Uri,

        [Parameter()]
        [string]
        $ContentType,

        [Parameter()]
        [Security.SecureString]
        $PersonalAccessToken,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter()]
        [string]
        $Proxy,

        [Parameter()]
        [pscredential]
        $ProxyCredential, 

        [Parameter()]
        [string]
        $Path
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
        If ($Body)
        {
            $invokeRestMethodSplat.Body = ConvertTo-Json -InputObject $Body -Depth 20
        }
        If ($Proxy)
        {
            $invokeRestMethodSplat.Proxy = $Proxy
            If ($ProxyCredential)
            {
                $invokeRestMethodSplat.ProxyCredential = $ProxyCredential
            }
            else
            {
                $invokeRestMethodSplat.ProxyUseDefaultCredentials = $true
            }
        }
        If ($Path)
        {
            $invokeRestMethodSplat.OutFile = $Path
        }
        $authenticatedRestMethodSplat = Set-APAuthenticationType -InputObject $invokeRestMethodSplat -Credential $Credential -PersonalAccessToken $PersonalAccessToken
        $results = Invoke-WebRequest @authenticatedRestMethodSplat
        If (@(200, 201) -contains $results.StatusCode)
        {
            $content = ($results.Content | ConvertFrom-Json)
            If ($content)
            {
                If ($results.Headers.'X-MS-ContinuationToken')
                {
                
                    If ($content.value)
                    {
                        $continuationToken = $results.Headers.'X-MS-ContinuationToken'
                        if ($continuationToken -is [array]) {
                            $continuationToken = $continuationToken[0]
                        }
                        return @{
                            continuationToken = $continuationToken
                            count             = $content.count
                            value             = $content.value
                        }
                    }
                    else
                    {
                        $continuationToken = $results.Headers.'X-MS-ContinuationToken'
                        if ($continuationToken -is [array]) {
                            $continuationToken = $continuationToken[0]
                        }
                        return @{
                            continuationToken = $continuationToken
                            value             = $content
                        }
                    }
                }
                else
                {
                    If ($content.value)
                    {
                        return @{
                            count = $content.count
                            value = $content.value
                        }
                    }
                    else
                    {
                        return @{
                            value = $content
                        }
                    }
                }
            }
            else
            {
                return
            }
        }
    }
    
    end
    {
    }
}
