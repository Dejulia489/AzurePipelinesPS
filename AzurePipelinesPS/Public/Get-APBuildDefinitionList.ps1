function Get-APBuildDefinitionList
{
    <#
    .SYNOPSIS

    Returns a list of Azure Pipeline build definitions.

    .DESCRIPTION

    Returns a list of Azure Pipeline build definitions based on a filter query.

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

    .PARAMETER Session

    Azure DevOps PS session, created by New-APSession.

    .PARAMETER TaskIdFilter

    If specified, filters to definitions that use the specified task.

    .PARAMETER IncludeLatestBuilds

    Indicates whether to return the latest and latest completed builds for this definition.

    .PARAMETER IncludeAllProperties

    Indicates whether to return the latest and latest completed builds for this definition.

    .PARAMETER NotBuiltAfter

    If specified, filters to definitions that do not have builds after this date.    

    .PARAMETER BuiltAfter

    If specified, filters to definitions that have builds after this date.

    .PARAMETER Path

    If specified, filters to definitions under this folder.

    .PARAMETER DefinitionIds

    A comma-delimited list that specifies the IDs of definitions to retrieve.

    .PARAMETER MinMetricsTime

    If specified, indicates the date from which metrics should be included.

    .PARAMETER ContinuationToken

    A continuation token, returned by a previous call to this method, that can be used to return the next set of definitions.

    .PARAMETER Top

    The maximum number of definitions to return.

    .PARAMETER QueryOrder

    Indicates the order in which definitions should be returned.

    .PARAMETER RepositoryType

    If specified, filters to definitions that have a repository of this type.

    .PARAMETER RepositoryId

    A repository ID. If specified, filters to definitions that use this repository.

    .PARAMETER Name

    If specified, filters to definitions whose names match this pattern.

    .PARAMETER YamlFilename

    If specified, filters to YAML definitions that match the given filename.

    .INPUTS
    
    None, does not support pipeline.

    .OUTPUTS

    PSObject, Azure Pipelines build(s)

    .EXAMPLE

    Returns the AP build definition list for 'myFirstProject'.

    Get-APBuildDefinitionList -Instance 'https://dev.azure.com' -Collection 'myCollection' -Project 'myFirstProject'

    .LINK

    https://docs.microsoft.com/en-us/rest/api/vsts/build/definitions/get?view=vsts-rest-5.0
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

        [Parameter(Mandatory,
            ParameterSetName = 'BySession')]
        [object]
        $Session,

        [Parameter()]
        [string]
        $TaskIdFilter,

        [Parameter()]
        [bool]
        $IncludeLatestBuilds,

        [Parameter()]
        [bool]
        $IncludeAllProperties,

        [Parameter()]
        [datetime]
        $NotBuiltAfter,

        [Parameter()]
        [datetime]
        $BuiltAfter,

        [Parameter()]
        [string]
        $Path,

        [Parameter()]
        [int[]]
        $DefinitionIds,

        [Parameter()]
        [datetime]
        $MinMetricsTime,

        [Parameter()]
        [string]
        $ContinuationToken,

        [Parameter()]
        [int]
        $Top,

        [Parameter()]
        [string]
        [ValidateSet('ascending', 'descending')]
        $QueryOrder,

        [Parameter()]
        [string]
        $RepositoryType,

        [Parameter()]
        [string]
        $RepositoryId,

        [Parameter()]
        [string]
        $Name,

        [Parameter()]
        [string]
        $YamlFilename
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
        $apiEndpoint = Get-APApiEndpoint -ApiType 'build-definitions'
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
            Method     = 'GET'
            Uri        = $uri
            Credential = $Credential
            PersonalAccessToken = $PersonalAccessToken
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