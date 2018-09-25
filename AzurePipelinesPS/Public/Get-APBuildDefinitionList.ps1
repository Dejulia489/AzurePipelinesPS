function Get-APBuildDefinitionList
{
    <#
    .SYNOPSIS

    Returns a list of Azure Pipeline build definitions(s).

    .DESCRIPTION

    Returns a list of Azure Pipeline build definitions(s) based on a filter query, if one is not provided the default will return all available definitions for the project provided.

    .PARAMETER Instance

    The Team Services account or TFS server.

    .PARAMETER Collection

    The value for collection should be DefaultCollection for both Team Services and TFS.

    .PARAMETER Project

    Project ID or project name.

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

    .PARAMETER ApiVersion

    Version of the api to use.

    .PARAMETER Credential

    Specifies a user account that has permission to send the request.

    .INPUTS
    

    .OUTPUTS

    PSObject, Azure Pipelines build(s)

    .EXAMPLE

    C:\PS> Get-APBuildDefinitionList -Instance 'https://myproject.visualstudio.com' -Collection 'DefaultCollection' -Project 'myFirstProject'

    .LINK

    https://docs.microsoft.com/en-us/rest/api/vsts/build/definitions/get?view=vsts-rest-5.0
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
        $TaskIdFilter,

        [Parameter(ParameterSetName = 'ByQuery')]
        [bool]
        $IncludeLatestBuilds,

        [Parameter(ParameterSetName = 'ByQuery')]
        [bool]
        $IncludeAllProperties,

        [Parameter(ParameterSetName = 'ByQuery')]
        [datetime]
        $NotBuiltAfter,

        [Parameter(ParameterSetName = 'ByQuery')]
        [datetime]
        $BuiltAfter,

        [Parameter(ParameterSetName = 'ByQuery')]
        [string]
        $Path,

        [Parameter(ParameterSetName = 'ByQuery')]
        [int[]]
        $DefinitionIds,

        [Parameter(ParameterSetName = 'ByQuery')]
        [datetime]
        $MinMetricsTime,

        [Parameter(ParameterSetName = 'ByQuery')]
        [string]
        $ContinuationToken,

        [Parameter(ParameterSetName = 'ByQuery')]
        [int]
        $Top,

        [Parameter(ParameterSetName = 'ByQuery')]
        [string]
        [ValidateSet('ascending', 'descending')]
        $QueryOrder,

        [Parameter(ParameterSetName = 'ByQuery')]
        [string]
        $RepositoryType,

        [Parameter(ParameterSetName = 'ByQuery')]
        [string]
        $RepositoryId,

        [Parameter(ParameterSetName = 'ByQuery')]
        [string]
        $Name,

        [Parameter(ParameterSetName = 'ByQuery')]
        [string]
        $YamlFilename,

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

        $apiEndpoint = Get-APApiEndpoint -ApiType 'build-definitions'
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
        If ($results.count -eq 0)
        {
            Write-Error "[$($MyInvocation.MyCommand.Name)]: Unable to locate build." -ErrorAction Stop
        }
        ElseIf ($results.value)
        {
            return $results.value
        }
        Else
        {
            return $results
        }
    }
    
    end
    {
    }
}