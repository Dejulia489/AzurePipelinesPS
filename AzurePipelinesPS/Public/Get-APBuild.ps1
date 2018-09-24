function Get-APBuild
{
    <#
    .SYNOPSIS

    Returns Azure Pipeline build(s).

    .DESCRIPTION

    Returns Azure Pipeline build(s) based on a filter query, if one is not provided the default will return all available builds for the project provided.

    .PARAMETER Instance
    
    The Team Services account or TFS server.
    
    .PARAMETER Collection
    
    The value for collection should be DefaultCollection for both Team Services and TFS.

    .PARAMETER Project
    
    Project ID or project name.

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

    .PARAMETER ApiVersion
    
    Version of the api to use.

    .PARAMETER Credential

    Specifies a user account that has permission to send the request.

    .INPUTS
    

    .OUTPUTS

    PSObject, Azure Pipelines build(s)

    .EXAMPLE

    C:\PS> Get-APBuild -Instance 'https://myproject.visualstudio.com' -Collection 'DefaultCollection' -Project 'myFirstProject'

    .LINK

    https://docs.microsoft.com/en-us/rest/api/vsts/build/builds/list?view=vsts-rest-5.0
    #>
    [CmdletBinding(DefaultParameterSetName = 'ByList')]
    Param
    (
        [Parameter()]
        [uri]
        $Instance = (Get-APModuleData).Instance,

        [Parameter()]
        [string]
        $Collection = (Get-APModuleData).Collection,

        [Parameter(Mandatory)]
        [string]
        $Project,

        [Parameter(ParameterSetName = 'ByQuery')]
        [string]
        $RepositoryId,

        [Parameter(ParameterSetName = 'ByQuery')]
        [string[]]
        $BuildIds,

        [Parameter(ParameterSetName = 'ByQuery')]
        [string]
        $BranchName,

        [Parameter(ParameterSetName = 'ByQuery')]
        [string]
        [ValidateSet('ascending', 'descending')]
        $QueryOrder,

        [Parameter(ParameterSetName = 'ByQuery')]
        [ValidateSet('excludeDeleted', 'includeDeleted', 'onlyDeleted')]
        [string]
        $DeletedFilter,   
        
        [Parameter(ParameterSetName = 'ByQuery')]
        [int]
        $MaxBuildsPerDefinition,

        [Parameter(ParameterSetName = 'ByQuery')]
        [string]
        $ContinuationToken,

        [Parameter(ParameterSetName = 'ByQuery')]
        [int]
        $Top,

        [Parameter(ParameterSetName = 'ByQuery')]
        [string[]]
        $Properties,

        [Parameter(ParameterSetName = 'ByQuery')]
        [string[]]
        $TagFilters,

        [Parameter(ParameterSetName = 'ByQuery')]
        [ValidateSet('canceled', 'failed', 'none', 'partiallySucceeded', 'succeeded')]
        [string]
        $ResultFilter,

        [Parameter(ParameterSetName = 'ByQuery')]
        [ValidateSet('all', 'cancelling', 'completed', 'inProgress', 'none', 'notStarted', 'postponed')]
        [string]
        $StatusFilter,

        [Parameter(ParameterSetName = 'ByQuery')]
        [ValidateSet('all', 'batchedCI', 'buildCompletion', 'checkInShelveset', 'individualCI', 'manual', 'none', 'pullRequest', 'schedule', 'triggered', 'userCreated', 'validateShelveset')]
        [string]
        $ReasonFilter,

        [Parameter(ParameterSetName = 'ByQuery')]
        [string]
        $RequestedFor,

        [Parameter(ParameterSetName = 'ByQuery')]
        [datetime]
        $MaxTime,

        [Parameter(ParameterSetName = 'ByQuery')]
        [datetime]
        $MinTime,

        [Parameter(ParameterSetName = 'ByQuery')]
        [string]
        $BuildNumber,

        [Parameter(ParameterSetName = 'ByQuery')]
        [int[]]
        $Queues,

        [Parameter(ParameterSetName = 'ByQuery')]
        [string[]]
        $Definitions,

        [Parameter(ParameterSetName = 'ByQuery')]
        [string]
        $RepositoryType,

        [Parameter()]
        [string]
        $ApiVersion = (Get-APApiVersion), 

        [Parameter()]
        [pscredential]
        $Credential
    )

    begin
    {
    }
    
    process
    {

        $apiEndpoint = Get-APApiEndpoint -ApiType 'build-builds'
        $setAPUriSplat = @{
            Collection  = $Collection
            Instance    = $Instance
            Project     = $Project
            ApiVersion  = $ApiVersion
            ApiEndpoint = $apiEndpoint
        }
        If ($PSCmdlet.ParameterSetName -eq 'ByQuery')
        {
            $nonQueryParams = @(
                'Instance',
                'Collection',
                'Project',
                'ApiVersion',
                'Credential',
                'Verbose',
                'Debug',
                'ErrorAction',
                'WarningAction', 
                'InformationAction', 
                'ErrorVariable', 
                'WarningVariable', 
                'InformationVariable', 
                'OutVariable', 
                'OutBuffer'
            )
            $queryParams = Foreach ($key in $PSBoundParameters.Keys)
            {
                If ($nonQueryParams -contains $key)
                {
                    Continue
                }
                ElseIf ($key -eq 'Top')
                {
                    "`$$key=$($PSBoundParameters.$key)"
                }
                ElseIf ($PSBoundParameters.$key.count)
                {
                    "$key={0}" -f ($PSBoundParameters.$key -join ',')
                }
                else
                {
                    "$key=$($PSBoundParameters.$key)"                    
                }
            }
            $setAPUriSplat.Query = ($queryParams -join '&').ToLower()
        }
        [uri] $uri = Set-APUri @setAPUriSplat
        $invokeAPRestMethodSplat = @{
            Method     = 'GET'
            Uri        = $uri
            Credential = $Credential
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