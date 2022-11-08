function Get-APBuildList
{
    <#
    .SYNOPSIS

    Returns a list of Azure Pipeline builds.

    .DESCRIPTION

    Returns a list of Azure Pipeline builds based on a filter query.

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

    If specified, filters to builds that built from this repository.

    .PARAMETER BuildIds

    A comma-delimited list that specifies the IDs of builds to retrieve.

    .PARAMETER BranchName

    If specified, filters to builds that built branches that built this branch.

    .PARAMETER QueryOrder

    The order in which builds should be returned.

    .PARAMETER DeletedFilter

    Indicates whether to exclude, include, or only return deleted builds.

    .PARAMETER MaxBuildsPerDefinition

    The maximum number of builds to return per definition.

    .PARAMETER ContinuationToken

    A continuation token, returned by a previous call to this method, that can be used to return the next set of builds.

    .PARAMETER Top

    The maximum number of builds to return.

    .PARAMETER Properties

    A comma-delimited list of properties to retrieve.

    .PARAMETER TagFilters

    A comma-delimited list of tags. If specified, filters to builds that have the specified tags.

    .PARAMETER ResultFilter
    
    If specified, filters to builds that match this result.

    .PARAMETER StatusFilter

    If specified, filters to builds that match this status.

    .PARAMETER ReasonFilter

    If specified, filters to builds that match this reason.

    .PARAMETER RequestedFor
	
    If specified, filters to builds requested for the specified user.

    .PARAMETER MaxTime
    	
    If specified, filters to builds requested for the specified user.

    .PARAMETER MinTime

    If specified, filters to builds that finished/started/queued after this date based on the queryOrder specified.

    .PARAMETER BuildNumber

    If specified, filters to builds that match this build number. Append * to do a prefix search.

    .PARAMETER Queues

    A comma-delimited list of queue IDs. If specified, filters to builds that ran against these queues.

    .PARAMETER Definitions

    A comma-delimited list of definition IDs. If specified, filters to builds for these definitions.

    .PARAMETER RepositoryType
	
    If specified, filters to builds that built from repositories of this type.

    .INPUTS
    
    None, does not support pipeline.

    .OUTPUTS

    PSObject, Azure Pipelines build(s)

    .EXAMPLE

    Returns AP build list for 'myFirstProject'

    Get-APBuildList -Instance 'https://dev.azure.com' -Collection 'myCollection' -Project 'myFirstProject'

    .LINK

    https://docs.microsoft.com/en-us/rest/api/vsts/build/builds/list?view=vsts-rest-5.0
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

        [Parameter()]
        [string]
        $RepositoryId,

        [Parameter()]
        [int[]]
        $BuildIds,

        [Parameter()]
        [string]
        $BranchName,

        [Parameter()]
        [string]
        [ValidateSet('finishTimeAscending', 'finishTimeDescending', 'queueTimeAscending', 'queueTimeDescending', 'startTimeAscending', 'startTimeDescending')]
        $QueryOrder,

        [Parameter()]
        [ValidateSet('excludeDeleted', 'includeDeleted', 'onlyDeleted')]
        [string]
        $DeletedFilter,   
        
        [Parameter()]
        [int]
        $MaxBuildsPerDefinition,

        [Parameter()]
        [string]
        $ContinuationToken,

        [Parameter()]
        [int]
        $Top,

        [Parameter()]
        [string[]]
        $Properties,

        [Parameter()]
        [string[]]
        $TagFilters,

        [Parameter()]
        [ValidateSet('canceled', 'failed', 'none', 'partiallySucceeded', 'succeeded')]
        [string]
        $ResultFilter,

        [Parameter()]
        [ValidateSet('all', 'cancelling', 'completed', 'inProgress', 'none', 'notStarted', 'postponed')]
        [string]
        $StatusFilter,

        [Parameter()]
        [ValidateSet('all', 'batchedCI', 'buildCompletion', 'checkInShelveset', 'individualCI', 'manual', 'none', 'pullRequest', 'schedule', 'triggered', 'userCreated', 'validateShelveset')]
        [string]
        $ReasonFilter,

        [Parameter()]
        [string]
        $RequestedFor,

        [Parameter()]
        [datetime]
        $MaxTime,

        [Parameter()]
        [datetime]
        $MinTime,

        [Parameter()]
        [string]
        $BuildNumber,

        [Parameter()]
        [int[]]
        $Queues,

        [Parameter()]
        [int[]]
        $Definitions,

        [Parameter()]
        [string]
        $RepositoryType
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
        $apiEndpoint = Get-APApiEndpoint -ApiType 'build-builds'
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
        $invokeAPWebRequestSplat = @{
            Method              = 'GET'
            Uri                 = $uri
            Credential          = $Credential
            PersonalAccessToken = $PersonalAccessToken
            Proxy               = $Proxy
            ProxyCredential     = $ProxyCredential
        }
        $results = Invoke-APWebRequest @invokeAPWebRequestSplat
        If ($results.continuationToken -and (-not($PSBoundParameters.ContainsKey('Top'))))
        {
            $results.value
            $null = $PSBoundParameters.Remove('ContinuationToken')
            Get-APBuildList @PSBoundParameters -ContinuationToken $results.continuationToken
        }
        elseIf ($results.value.count -eq 0)
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