function Get-APReleaseList
{
    <#
    .SYNOPSIS

    Returns a list of Azure Pipeline releases.

    .DESCRIPTION

    Returns a list of Azure Pipeline releases based on a filter query.

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

    .INPUTS
    

    .OUTPUTS

    PSObject, Azure Pipelines release(s)

    .EXAMPLE

    C:\PS> Get-APRelease -Instance 'https://dev.azure.com' -Collection 'myCollection' -Project 'myFirstProject'

    .LINK

    https://docs.microsoft.com/en-us/rest/api/vsts/release/releases/list?view=vsts-rest-5.0
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
        $PropertyFilters,

        [Parameter()]
        [string]
        $TagFilter,

        [Parameter()]
        [bool]
        $IsDeleted,

        [Parameter()]
        [string]
        $SourceBranchFilter,

        [Parameter()]
        [string]
        $ArtifactVersionId,

        [Parameter()]
        [string]
        $SourceId,

        [Parameter()]
        [string]
        $ArtifactTypeId,

        [Parameter()]
        [string]
        [ValidateSet('approvals', 'artifacts', 'environments', 'manualInterventions', 'none', 'tags', 'variables')]
        $Expand,

        [Parameter()]
        [int]
        $ContinuationToken,

        [Parameter()]
        [int]
        $Top,

        [Parameter()]
        [string]
        [ValidateSet('ascending', 'descending')]
        $QueryOrder,

        [Parameter()]
        [datetime]
        $MaxCreatedTime,

        [Parameter()]
        [datetime]
        $MinCreatedTime,

        [Parameter()]
        [string]
        $EnvironmentStatusFilter,

        [Parameter()]
        [string]
        $StatusFilter,

        [Parameter()]
        [string]
        $CreatedBy,

        [Parameter()]
        [string]
        $SearchText,

        [Parameter()]
        [int]
        $DefinitionEnvironmentId,

        [Parameter()]
        [int]
        $DefinitionId,

        [Parameter()]
        [int]
        $ReleaseIdFilter
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
                $ApiVersion = (Get-APApiVersion -Version $currentSession.Version)
                $PersonalAccessToken = $currentSession.PersonalAccessToken
            }
        }
    }
    
    process
    {
        $apiEndpoint = Get-APApiEndpoint -ApiType 'release-releases'
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