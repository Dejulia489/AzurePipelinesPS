function Remove-APInstalledExtensionDocument
{
    <#
    .SYNOPSIS

    Removes an Azure Pipeline installed extension document by id.

    .DESCRIPTION

    Removes an Azure Pipeline installed extension document by id.
    The extension details can be retrieved by using Get-APInstalledExtensionList.
    The document id can be retrieced by using Get-APInstalledExtensionDocumentList.

    .PARAMETER Instance
    
    The Team Services account or TFS server.
    
    .PARAMETER Collection
    
    For Azure DevOps the value for collection should be the name of your orginization. 
    For both Team Services and TFS The value should be DefaultCollection unless another collection has been created.

    .PARAMETER ApiVersion
    
    Version of the api to use.

    .PARAMETER PersonalAccessToken
    
    Personal access token used to authenticate that has been converted to a secure string. 
    It is recomended to uses an Azure Pipelines PS session to pass the personal access token parameter among funcitons, See New-APSession.
    https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=vsts
    
    .PARAMETER Credential

    Specifies a user account that has permission to send the request.

    .PARAMETER Proxy
    
    Use a proxy server for the request, rather than connecting directly to the Internet resource. Enter the URI of a network proxy server.

    .PARAMETER ProxyCredential
    
    Specifie a user account that has permission to use the proxy server that is specified by the -Proxy parameter. The default is the current user.

    .PARAMETER Session

    Azure DevOps PS session, created by New-APSession.

    .PARAMETER PublisherName

    Name of the publisher. Example: "MDSolutions".

    .PARAMETER ExtensionName
	
    Name of the extension. Example: "WindowsServiceManager".

    .PARAMETER ScopeType
	
    The scope of where the document is stored. Can be Default or User.

    .PARAMETER ScopeValue

    The value of the scope where the document is stored. Can be Current or Me.

    .PARAMETER DocumentCollection

    The name of the document collection.

    .PARAMETER DocumentId

    The id of the document.

    .INPUTS
    
    None, does not support pipeline.

    .OUTPUTS

    None, does not support output.

    .EXAMPLE

    Removes the WindowsServiceManager extension document.

    Remove-APInstalledExtensionDocument -Instance 'https://dev.azure.com' -Collection 'myCollection' -ExtensionName 'WindowsServiceManager' -Published 'MDSolutions' -ScopeType 'Default' -ScopeValue 'Current' -DocumentId 'theDocumentGuid'

    .LINK

    Windows Service Manager extension:
    https://marketplace.visualstudio.com/items?itemName=MDSolutions.WindowsServiceManagerWindowsServiceManager

    https://docs.microsoft.com/en-us/rest/api/azure/devops/extensionmanagement/installed%20extensions?view=azure-devops-rest-5.0
    #>
    [CmdletBinding(DefaultParameterSetName = 'ByPersonalAccessToken')]
    Param
    (
        [Parameter(Mandatory,
            ParameterSetName = 'ByPersonalAccessToken')]
        [Parameter(Mandatory,
            ParameterSetName = 'ByCredential')]
        [uri]
        $Instance,

        [Parameter(Mandatory,
            ParameterSetName = 'ByPersonalAccessToken')]
        [Parameter(Mandatory,
            ParameterSetName = 'ByCredential')]
        [string]
        $Collection,

        [Parameter(Mandatory,
            ParameterSetName = 'ByPersonalAccessToken')]
        [Parameter(Mandatory,
            ParameterSetName = 'ByCredential')]
        [string]
        $ApiVersion,

        [Parameter(ParameterSetName = 'ByPersonalAccessToken')]
        [Security.SecureString]
        $PersonalAccessToken,

        [Parameter(ParameterSetName = 'ByCredential')]
        [pscredential]
        $Credential,

        [Parameter(ParameterSetName = 'ByPersonalAccessToken')]
        [Parameter(ParameterSetName = 'ByCredential')]
        [string]
        $Proxy,

        [Parameter(ParameterSetName = 'ByPersonalAccessToken')]
        [Parameter(ParameterSetName = 'ByCredential')]
        [pscredential]
        $ProxyCredential,

        [Parameter(Mandatory,
            ParameterSetName = 'BySession')]
        [object]
        $Session,

        [Parameter(Mandatory)]
        [string]
        $PublisherName,

        [Parameter(Mandatory)]
        [string]
        $ExtensionName,

        [Parameter(Mandatory)]
        [ValidateSet('Default', 'User')]
        [string]
        $ScopeType,

        [Parameter(Mandatory)]
        [ValidateSet('Current', 'Me')]
        [string]
        $ScopeValue,

        [Parameter(Mandatory)]
        [string]
        $DocumentCollection, 

        [Parameter(Mandatory)]
        [string]
        $DocumentId
    )

    begin
    {
        If ($PSCmdlet.ParameterSetName -eq 'BySession')
        {
            $currentSession = $Session | Get-APSession
            If ($currentSession)
            {
                $Instance = $currentSession.Instance
                $Collection = $currentSession.Collection
                $PersonalAccessToken = $currentSession.PersonalAccessToken
                $Credential = $currentSession.Credential
                $Proxy = $currentSession.Proxy
                $ProxyCredential = $currentSession.ProxyCredential
                If ($currentSession.Version)
                {
                    $ApiVersion = (Get-APApiVersion -Version $currentSession.Version)
                }
                else
                {
                    $ApiVersion = $currentSession.ApiVersion
                }
            }
        }
    }
    
    process
    {
        $apiEndpoint = (Get-APApiEndpoint -ApiType 'extensionmanagement-documentId') -f $PublisherName, $ExtensionName, $ScopeType, $ScopeValue, $DocumentCollection, $DocumentId
        $queryParameters = Set-APQueryParameters -InputObject $PSBoundParameters
        $setAPUriSplat = @{
            Collection  = $Collection
            Instance    = $Instance
            ApiVersion  = $ApiVersion
            ApiEndpoint = $apiEndpoint
            Query       = $queryParameters
        }
        [uri] $uri = Set-APUri @setAPUriSplat
        $invokeAPRestMethodSplat = @{
            Method              = 'DELETE'
            Uri                 = $uri
            Credential          = $Credential
            PersonalAccessToken = $PersonalAccessToken
            Proxy               = $Proxy
            ProxyCredential     = $ProxyCredential
        }
        Invoke-APRestMethod @invokeAPRestMethodSplat 
    }
    
    end
    {
    }
}