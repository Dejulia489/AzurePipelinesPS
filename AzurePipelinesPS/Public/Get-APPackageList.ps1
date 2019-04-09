function Get-APPackageList
{
    <#
    .SYNOPSIS

    Returns a list of Azure Pipeline packages.

    .DESCRIPTION

    Returns a list of Azure Pipelin packages based on a filter query.

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

    .PARAMETER FeedId

    Name or Id of the feed.

    .PARAMETER IsCached

    [Obsolete] Used for legacy scenarios and may be removed in future versions.

    .PARAMETER IncludeDeleted

    Return deleted or unpublished versions of packages in the response. Default is False.

    .PARAMETER Skip

    Skip the first N packages (or package versions where getTopPackageVersions=true)

    .PARAMETER Top

    Get the top N packages (or package versions where getTopPackageVersions=true)

    .PARAMETER IncludeDescription

    Return the description for every version of each package in the response. Default is False.

    .PARAMETER IsRelease

    Only applicable for Nuget packages. Use this to filter the response when includeAllVersions is set to true. Default is True (only return packages without prerelease versioning).
    
    .PARAMETER GetTopPackageVersions

    Changes the behavior of $top and $skip to return all versions of each package up to $top. Must be used in conjunction with includeAllVersions=true

    .PARAMETER IsListed

    Only applicable for NuGet packages, setting it for other package types will result in a 404. If false, delisted package versions will be returned. Use this to filter the response when includeAllVersions is set to true. Default is unset (do not return delisted packages).

    .PARAMETER IncludeAllVersions

    True to return all versions of the package in the response. Default is false (latest version only).

    .PARAMETER IncludeUrls

    True to return REST Urls with the response. Default is True.

    .PARAMETER NormalizedPackageName
    	
    [Obsolete] Used for legacy scenarios and may be removed in future versions.

    .PARAMETER PackageNameQuery

    Filter to packages that contain the provided string. Characters in the string must conform to the package name constraints.

    .PARAMETER ProtocolType

    One of the supported artifact package types.

    .PARAMETER DirectUpstreamId

    Filter results to return packages from a specific upstream.

    .INPUTS
    
    None, does not support pipeline.

    .OUTPUTS

    PSObject, Azure Pipelines package(s)

    .EXAMPLE

    Returns AP package list with the feed id of 'myFeed'.

    Get-APPackageList -Instance 'https://dev.azure.com' -Collection 'myCollection' -FeedId 'myFeed'

    .LINK

    https://docs.microsoft.com/en-us/rest/api/azure/devops/artifacts/artifact%20%20details/get%20packages?view=azure-devops-rest-5.0
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
        $FeedId,

        [Parameter()]
        [bool]
        $IsCached,
        
        [Parameter()]
        [bool]
        $IncludeDeleted,

        [Parameter()]
        [int]
        $Skip,

        [Parameter()]
        [int]
        $Top,

        [Parameter()]
        [bool]
        $IncludeDescription,
        
        [Parameter()]
        [bool]
        $IsRelease,

        [Parameter()]
        [bool]
        $GetTopPackageVersions,

        [Parameter()]
        [bool]
        $IsListed,

        [Parameter()]
        [bool]
        $IncludeAllVersions,

        [Parameter()]
        [bool]
        $IncludeUrls,

        [Parameter()]
        [string]
        $NormalizedPackageName,

        [Parameter()]
        [string]
        $PackageNameQuery,

        [Parameter()]
        [string]
        $ProtocolType,

        [Parameter()]
        [string]
        $DirectUpstreamId
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
        $apiEndpoint = (Get-APApiEndpoint -ApiType 'feed-packages') -f $FeedId 
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
            Method              = 'GET'
            Uri                 = $uri
            Credential          = $Credential
            PersonalAccessToken = $PersonalAccessToken
            Proxy               = $Proxy
            ProxyCredential     = $ProxyCredential
        }
        $results = Invoke-APRestMethod @invokeAPRestMethodSplat 
        If ($results.count -eq 0)
        {
            Return
        }
        ElseIf ($results.value)
        {
            Return $results.value
        }
        Else
        {
            Return $results
        }
    }
    
    end
    {
    }
}