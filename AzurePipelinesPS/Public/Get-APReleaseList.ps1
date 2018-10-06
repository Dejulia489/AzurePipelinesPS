function Get-APReleaseList
{
    <#
    .SYNOPSIS

    Returns a list of Azure Pipeline release(s).

    .DESCRIPTION

    Returns a list of Azure Pipeline release(s) based on a filter query, if one is not provided the default will return the top 50 releases for the project provided.

    .PARAMETER Instance
    
    The Team Services account or TFS server.
    
    .PARAMETER Collection
    
    The value for collection should be DefaultCollection for both Team Services and TFS.

    .PARAMETER Project
    
    Project ID or project name.

    .PARAMETER PropertyFilters
    
    A comma-delimited list of extended properties to retrieve.

    .PARAMETER TagFilter
    
    A comma-delimited list of tags. Only releases with these tags will be returned.

    .PARAMETER IsDeleted
    
    Gets the soft deleted releases, if true.

    .PARAMETER SourceBranchFilter
    
    Releases with given sourceBranchFilter will be returned.

    .PARAMETER ArtifactVersionId
    
    Releases with given artifactVersionId will be returned. E.g. in case of Build artifactType, it is buildId.

    .PARAMETER SourceId
    
    Unique identifier of the artifact used. e.g. For build it would be {projectGuid}:{BuildDefinitionId}, for Jenkins it would be {JenkinsConnectionId}:{JenkinsDefinitionId}, for TfsOnPrem it would be {TfsOnPremConnectionId}:{ProjectName}:{TfsOnPremDefinitionId}. For third-party artifacts e.g. TeamCity, BitBucket you may refer 'uniqueSourceIdentifier' inside vss-extension.json https://github.com/Microsoft/vsts-rm-extensions/blob/master/Extensions.

    .PARAMETER ArtifactTypeId
    
    Releases with given artifactTypeId will be returned. Values can be Build, Jenkins, GitHub, Nuget, Team Build (external), ExternalTFSBuild, Git, TFVC, ExternalTfsXamlBuild.

    .PARAMETER Expand
    
    The property that should be expanded in the list of releases.

    .PARAMETER ContinuationToken
    
    Gets the releases after the continuation token provided.

    .PARAMETER Top
    
    Number of releases to get. Default is 50.

    .PARAMETER QueryOrder
    
    Gets the results in the defined order of created date for releases. Default is descending.

    .PARAMETER MaxCreatedTime

    Releases that were created before this time.

    .PARAMETER MinCreatedTime
    
    Releases that were created after this time.

    .PARAMETER EnvironmentStatusFilter
    
    Undefined, see link for documentation

    .PARAMETER StatusFilter
    
    Releases that have this status.

    .PARAMETER CreatedBy
    
    Releases created by this user.

    .PARAMETER SearchText
    
    Releases with names starting with searchText.

    .PARAMETER DefinitionEnvironmentId
    
    Undefined, see link for documentation

    .PARAMETER DefinitionId
    
    Releases from this release definition Id.

    .PARAMETER ReleaseIdFilter
    
    A comma-delimited list of releases Ids. Only releases with these Ids will be returned.

    .PARAMETER ApiVersion
    
    Version of the api to use.

    .PARAMETER Credential

    Specifies a user account that has permission to send the request.

    .INPUTS
    

    .OUTPUTS

    PSObject, Azure Pipelines release(s)

    .EXAMPLE

    C:\PS> Get-APRelease -Instance 'https://myproject.visualstudio.com' -Collection 'DefaultCollection' -Project 'myFirstProject'

    .LINK

    https://docs.microsoft.com/en-us/rest/api/vsts/release/releases/list?view=vsts-rest-5.0
    #>
    [CmdletBinding(DefaultParameterSetName = 'Default')]
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
        $PropertyFilters,

        [Parameter(ParameterSetName = 'ByQuery')]
        [string]
        $TagFilter,

        [Parameter(ParameterSetName = 'ByQuery')]
        [bool]
        $IsDeleted,

        [Parameter(ParameterSetName = 'ByQuery')]
        [string]
        $SourceBranchFilter,

        [Parameter(ParameterSetName = 'ByQuery')]
        [string]
        $ArtifactVersionId,

        [Parameter(ParameterSetName = 'ByQuery')]
        [string]
        $SourceId,

        [Parameter(ParameterSetName = 'ByQuery')]
        [string]
        $ArtifactTypeId,

        [Parameter(ParameterSetName = 'ByQuery')]
        [string]
        [ValidateSet('approvals', 'artifacts', 'environments', 'manualInterventions', 'none', 'tags', 'variables')]
        $Expand,

        [Parameter(ParameterSetName = 'ByQuery')]
        [int]
        $ContinuationToken,

        [Parameter(ParameterSetName = 'ByQuery')]
        [int]
        $Top,

        [Parameter(ParameterSetName = 'ByQuery')]
        [string]
        [ValidateSet('ascending', 'descending')]
        $QueryOrder,

        [Parameter(ParameterSetName = 'ByQuery')]
        [datetime]
        $MaxCreatedTime,

        [Parameter(ParameterSetName = 'ByQuery')]
        [datetime]
        $MinCreatedTime,

        [Parameter(ParameterSetName = 'ByQuery')]
        [string]
        $EnvironmentStatusFilter,

        [Parameter(ParameterSetName = 'ByQuery')]
        [string]
        $StatusFilter,

        [Parameter(ParameterSetName = 'ByQuery')]
        [string]
        $CreatedBy,

        [Parameter(ParameterSetName = 'ByQuery')]
        [string]
        $SearchText,

        [Parameter(ParameterSetName = 'ByQuery')]
        [int]
        $DefinitionEnvironmentId,

        [Parameter(ParameterSetName = 'ByQuery')]
        [int]
        $DefinitionId,

        [Parameter(ParameterSetName = 'ByQuery')]
        [int]
        $ReleaseIdFilter,

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
        $apiEndpoint = Get-APApiEndpoint -ApiType 'release-release'
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