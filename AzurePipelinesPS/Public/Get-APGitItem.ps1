function Get-APGitItem
{
    <#
    .SYNOPSIS

    Returns item metadata and/or content for a single item.

    .DESCRIPTION

    Returns item metadata and/or content for a single item by repository id. 
    The id can be retrieved by using Get-APRepository.
    The download parameter is to indicate whether the content should be available as a download or just sent as a stream in the response. Doesn't apply to zipped content, which is always returned as a download.

    .PARAMETER Instance
    
    The Team Services account or TFS server.
    
    .PARAMETER Collection
    
    For Azure DevOps the value for collection should be the name of your orginization. 
    For both Team Services and TFS The value should be DefaultCollection unless another collection has been created.

    .PARAMETER Project
    
    Project ID or project name.

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

    .PARAMETER RepositoryId

    The id of the repository.

    .PARAMETER Path

    The item path.

    .PARAMETER ScopePath

    The path scope, defaults to null.

    .PARAMETER RecursionLevel

    The recursion level of this request, defaults to none.

    .PARAMETER IncludeContentMetadata

    Set to true to include content metadata, defaults to false.

    .PARAMETER LatestProcessedChange

    Set to true to include the latest changes, defaults to false.

    .PARAMETER Download

    Set to true to download the response as a file, defaults to false.

    .PARAMETER Format

    If specified, this overrides the HTTP Accept request header to return either 'json' or 'zip'. If $format is specified, then api-version should also be specified as a query parameter.

    .PARAMETER IncludeContent

    Set to true to include item content when requesting json, defaults to false.

    .PARAMETER ResolveLfs

    Set to true to resolve Git LFS pointer files to return actual content from Git LFS. Default is false.

    .INPUTS
    
    None, does not support pipeline.

    .OUTPUTS

    PSObject, git item metadata

    .EXAMPLE

    Returns the root of the repository with the name of 'myRepository'.

    $session = Get-APSession -SessionName 'mySession'
    $repository = Get-APRepositoryList -Session $session | ? name -eq 'myRepository'
    $getAPGitItemSplat = @{
        RepositoryId   = $repository.Id
        Session        = $session
    }
    Get-APGitItem @getAPGitItemSplat 

    .EXAMPLE

    Returns all files and folders at the path of 'src/My.Project/myContacts' by using 'full' recursion.

    $session = Get-APSession -SessionName 'mySession'
    $repository = Get-APRepositoryList -Session $session | ? name -eq 'myRepository'
    $getAPGitItemSplat = @{
        ScopePath      = 'src/My.Project/myContacts'
        RecursionLevel = 'full'
        RepositoryId   = $repository.Id
        Session        = $session
    }
    Get-APGitItem @getAPGitItemSplat 

    .EXAMPLE

    Returns the content of the powershell script 'myDeployment.ps1'. Save the output of Get-APGitItem and pass it to Out-File to save the content to a file.

    $session = Get-APSession -SessionName 'mySession'
    $repository = Get-APRepositoryList -Session $session | ? name -eq 'myRepository'
    $getAPGitItemSplat = @{
        ScopePath      = 'src/Deployment/myDeployment.ps1'
        RepositoryId   = $repository.Id
        Session        = $session
    }
    Get-APGitItem @getAPGitItemSplat 

    .LINK

    https://docs.microsoft.com/en-us/rest/api/azure/devops/git/items/get?view=azure-devops-rest-5.0
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
        $Project,

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
        [ArgumentCompleter( {
                param ( $commandName,
                    $parameterName,
                    $wordToComplete,
                    $commandAst,
                    $fakeBoundParameters )
                $possibleValues = Get-APSession | Select-Object -ExpandProperty SessionNAme
                $possibleValues.Where( { $PSitem -match $wordToComplete })
            })]
        [object]
        $Session,

        [Parameter(Mandatory)]
        [string]
        $RepositoryId, 

        [Parameter()]
        [string]
        $Path,

        [Parameter()]
        [string]
        $ScopePath,

        [Parameter()]
        [ValidateSet('full', 'none', 'oneLevel', 'oneLevelPlusNestedEmptyFolders')]
        [string]
        $RecursionLevel, 

        [Parameter()]
        [bool]
        $IncludeContentMetadata, 

        [Parameter()]
        [bool]
        $LatestProcessedChange,

        [Parameter()]
        [bool]
        $Download,

        [Parameter()]
        [string]
        $Format,

        [Parameter()]
        [bool]
        $IncludeContent,

        [Parameter()]
        [bool]
        $ResolveLfs,

        [Parameter()]
        [string]
        $VersionDescriptor_Version,

        [Parameter()]
        [ValidateSet('firstParent', 'none', 'previousChange')]
        [string]
        $VersionDescriptor_VersionOptions,

        [Parameter()]
        [ValidateSet('branch', 'tag', 'commit')]
        [string]
        $VersionDescriptor_VersionType
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
                $Project = $currentSession.Project
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
        $apiEndpoint = (Get-APApiEndpoint -ApiType 'git-items') -f $RepositoryId
        $queryParameters = Set-APQueryParameters -InputObject $PSBoundParameters
        $setAPUriSplat = @{
            Collection  = $Collection
            Instance    = $Instance
            Project     = $Project
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
        If ($results.value)
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