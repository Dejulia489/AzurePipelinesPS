function Register-APPSRepository
{
    <#
    .SYNOPSIS

    Registers a PSRepository to an Azure DevOps feed.

    .DESCRIPTION

    Registers a PSRepository to an Azure DevOps feed.
    A list of feeds can be retrieved with Get-APFeedList.

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

    .PARAMETER FeedName

    The name of the feed to register.

    .PARAMETER RepositoryName

    The name of the PSRepository. 

    .PARAMETER RepositoryCredential

    The credential used to register the PSRepository.

    .PARAMETER InstallationPolicy

    Specifies the installation policy. Valid values are: Trusted, UnTrusted. The default value is Trusted.

    .INPUTS
    
    None, does not support pipeline.

    .OUTPUTS

    PSObject, Azure Pipelines feed.

    .EXAMPLE

    .LINK

    https://docs.microsoft.com/en-us/rest/api/azure/devops/feed/feeds/queue?view=azure-devops-rest-5.0
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
        $FeedName,

        [Parameter(Mandatory)]
        [string]
        $RepositoryName,

        [Parameter()]
        [pscredential]
        $RepositoryCredential,

        [Parameter()]
        [ValidateSet('Trusted', 'UnTrusted')]
        [string]
        $InstallationPolicy = 'Trusted'
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
        $getAPFeedListSplat = @{
            Collection = $Collection
            Instance   = $Instance
            ApiVersion = $ApiVersion
        }
        If ($Credential)
        {
            $getAPFeedListSplat.Credential = $Credential
        }
        If ($PersonalAccessToken)
        {
            $getAPFeedListSplat.PersonalAccessToken = $PersonalAccessToken
        }
        If ($Proxy)
        {
            $getAPFeedListSplat.Proxy = $Proxy
        }
        If ($ProxyCredential)
        {
            $getAPFeedListSplat.ProxyCredential = $ProxyCredential
        }
        $feedListObject = Get-APFeedList @getAPFeedListSplat | Where-Object { $PSItem.Name -eq $FeedName }
        If ($feedListObject)
        {
            $apiEndpoint = (Get-APApiEndpoint -ApiType 'packaging-feedName') -f $FeedName
            $setAPUriSplat = @{
                Collection  = $Collection
                Instance    = $Instance
                Project     = $Project
                ApiVersion  = $ApiVersion
                ApiEndpoint = $apiEndpoint
                Query       = $queryParameters
            }
            [uri] $uri = Set-APUri @setAPUriSplat
        }
        else
        {
            Write-Error "[$($MyInvocation.MyCommand.Name)]: Unable to locate a feed with the name of [$FeedName]"
        }
        If ($uri)
        {
            $registerPSRepositorySplat = @{
                Name               = $RepositoryName
                PublishLocation    = $uri
                SourceLocation     = $uri
                InstallationPolicy = $InstallationPolicy
            }
            If ($RepositoryCredential)
            {
                $registerPSRepositorySplat.Credential = $RepositoryCredential
            }
            If ($Proxy)
            {
                $registerPSRepositorySplat.Proxy = $Proxy
            }
            If ($ProxyCredential)
            {
                $registerPSRepositorySplat.ProxyCredential = $ProxyCredential
            }
            Register-PSRepository @registerPSRepositorySplat
        }
    }
    
    end
    {
    }
}