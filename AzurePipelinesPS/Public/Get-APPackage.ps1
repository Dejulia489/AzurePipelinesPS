function Get-APPackage
{
    <#
    .SYNOPSIS

    Returns an of Azure Pipeline package.

    .DESCRIPTION

    Returns an Azure Pipeline package by package id.
    The package id can be retrieved by using Get-APPackageList.

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

    .PARAMETER PackageId

    The package Id (GUID Id, not the package name).

    .PARAMETER IncludeAllVersions

    True to return all versions of the package in the response. Default is false (latest version only).

    .PARAMETER IncludeUrls

    True to return REST Urls with the response. Default is True.

    .PARAMETER IsListed

    Only applicable for NuGet packages, setting it for other package types will result in a 404. If false, delisted package versions will be returned. Use this to filter the response when includeAllVersions is set to true. Default is unset (do not return delisted packages).

    .PARAMETER IsRelease

    Only applicable for Nuget packages. Use this to filter the response when includeAllVersions is set to true. Default is True (only return packages without prerelease versioning).

    .PARAMETER IncludeDeleted

    Return deleted or unpublished versions of packages in the response. Default is False.

    .PARAMETER IncludeDescription

    Return the description for every version of each package in the response. Default is False.

    .INPUTS
    
    None, does not support pipeline.

    .OUTPUTS

    PSObject, Azure Pipelines package

    .EXAMPLE

    Returns AP package with the feed id of 'myFeed' and the package id 'a9522a15-4318-4f82-9d87-ed926ddb5e12'.

    Get-APPackage -Instance 'https://dev.azure.com' -Collection 'myCollection' -FeedId 'myFeed' -PackageId 'a9522a15-4318-4f82-9d87-ed926ddb5e12'

    .LINK

    https://docs.microsoft.com/en-us/rest/api/azure/devops/artifacts/feed%20%20management/get%20feed?view=azure-devops-rest-5.0
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

        [Parameter(Mandatory)]
        [string]
        $PackageId,

        [Parameter()]
        [bool]
        $IncludeAllVersions,

        [Parameter()]
        [bool]
        $IncludeUrls,

        [Parameter()]
        [bool]
        $IsListed,

        [Parameter()]
        [bool]
        $IsRelease,

        [Parameter()]
        [bool]
        $IncludeDeleted,

        [Parameter()]
        [bool]
        $IncludeDescription
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
        $apiEndpoint = (Get-APApiEndpoint -ApiType 'feed-packageId') -f $FeedId, $PackageId
        $queryParameters = Set-APQueryParameters -InputObject $PSBoundParameters
        $setAPUriSplat = @{
            Collection          = $Collection
            Instance            = $Instance
            ApiVersion          = $ApiVersion
            ApiEndpoint         = $apiEndpoint
            Query               = $queryParameters
            ApiSubDomainSwitch = 'feeds'
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
            return
        }
        elseIf ($results.value)
        {
            return $results.value
        }
        else
        {
            return $results
        }
    }
    
    end
    {
    }
}