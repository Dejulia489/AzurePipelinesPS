function Get-APGitPullRequestList
{
    <#
    .SYNOPSIS

    Returns a list of pull requests.

    .DESCRIPTION

    Returns a list of pull requests matching a specified criteria..

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
    
    Specify a user account that has permission to use the proxy server that is specified by the -Proxy parameter. The default is the current user.

    .PARAMETER Session

    Azure DevOps PS session, created by New-APSession.
    
   .PARAMETER RepositoryId

    The repository ID of the pull request's target branch.

    .PARAMETER SearchCriteria_IncludeLinks

    Whether to include the _links field on the shallow references.

    .PARAMETER SearchCriteria_SourceRefName

    If set, search for pull requests from this branch.

    .PARAMETER SearchCriteria_SourceRepositoryId

    If set, search for pull requests whose source branch is in this repository.

    .PARAMETER SearchCriteria_TargetRefName

    If set, search for pull requests into this branch.

    .PARAMETER SearchCriteria_Status

    If set, search for pull requests that are in this state. Defaults to Active if unset.
    Acceptable values are (as of API version 5.1): 
        abandoned   :   Pull request is abandoned.
        active      :   Pull request is active.
        all         :   Used in pull request search criterias to include all statuses.
        completed   :   Pull request is completed.
        notSet      :   Status not set. Default state.

    .PARAMETER SearchCriteria_ReviewerId

    If set, search for pull requests that have this identity as a reviewer.

    .PARAMETER SearchCriteria_CreatorId

    If set, search for pull requests that were created by this identity.

    .PARAMETER SearchCriteria_RepositoryId

    If set, search for pull requests whose target branch is in this repository.

    .PARAMETER Skip

    The number of pull requests to ignore. For example, to retrieve results 101-150, set top to 50 and skip to 100.

    .PARAMETER Top

    The maximum number of pull requests to return.

    .INPUTS
    
    None, does not support pipeline.

    .OUTPUTS

    PSObject, pull requests

    .EXAMPLE

    Returns all active pull requests for repositoryId 'e0eb12ee-83f2-4446-ac51-d067949e3a78'

    Get-APGitPullRequestList -Instance 'https://dev.azure.com' -Collection 'myCollection' -Project 'myFirstProject' -RepositoryId 'e0eb12ee-83f2-4446-ac51-d067949e3a78'

    .LINK

    https://docs.microsoft.com/en-us/rest/api/azure/devops/git/pull%20requests/get%20pull%20requests?view=azure-devops-rest-5.1
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
        [object]
        $Session,

        [Parameter(Mandatory,
            ParameterSetName = 'ByPersonalAccessToken')]
        [Parameter(Mandatory,
            ParameterSetName = 'ByCredential')]
        [Parameter(Mandatory,
            ParameterSetName = 'BySession')]
        [string]
        $RepositoryId,

        [Parameter()]
        [boolean]
        $SearchCriteria_IncludeLinks,

        [Parameter()]
        [string]
        $SearchCriteria_SourceRefName,

        [Parameter()]
        [string]
        $SearchCriteria_SourceRepositoryId,

        [Parameter()]
        [string]
        $SearchCriteria_TargetRefName,

        [Parameter()]
        [string]
        [ValidateSet('abandoned', 'active', 'all', 'completed', 'notSet')]
        $SearchCriteria_Status,

        [Parameter()]
        [string]
        $SearchCriteria_ReviewerId,

        [Parameter()]
        [string]
        $SearchCriteria_CreatorId,

        [Parameter()]
        [string]
        $SearchCriteria_RepositoryId,

        [Parameter()]
        [int]
        $Skip,

        [Parameter()]
        [int]
        $Top
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
        $apiEndpoint = Get-APApiEndpoint -ApiType 'git-pullRequests'
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