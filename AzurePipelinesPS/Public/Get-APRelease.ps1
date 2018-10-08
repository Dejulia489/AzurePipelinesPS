function Get-APRelease
{
    <#
    .SYNOPSIS

    Returns Azure Pipeline release(s).

    .DESCRIPTION

    Returns Azure Pipeline release(s) based on a filter query, if one is not provided the default will return the top 50 releases for the project provided.

    .PARAMETER Instance
    
    The Team Services account or TFS server.
    
    .PARAMETER Collection
    
    The value for collection should be DefaultCollection for both Team Services and TFS.

    .PARAMETER Project
    
    Project ID or project name.

    .PARAMETER ReleaseId
    
    Id of the release.

    .PARAMETER ApprovalFilters
    
    A filter which would allow fetching approval steps selectively based on whether it is automated, or manual. This would also decide whether we should fetch pre and post approval snapshots. Assumes All by default.

    .PARAMETER PropertyFilters
    
    A comma-delimited list of extended properties to be retrieved. If set, the returned Release will contain values for the specified property Ids (if they exist). If not set, properties will not be included.

    .PARAMETER Expand
    
    A property that should be expanded in the release.

    .PARAMETER TopGateRecords
    
    Number of release gate records to get. Default is 5.

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

        [Parameter()]
        [string]
        $Project = (Get-APModuleData).Project,

        [Parameter(Mandatory)]
        [string]
        $ReleaseId,

        [Parameter(ParameterSetName = 'ByQuery')]
        [string]
        $ApprovalFilters,

        [Parameter(ParameterSetName = 'ByQuery')]
        [string]
        $PropertyFilters,

        [Parameter(ParameterSetName = 'ByQuery')]
        [string]
        [ValidateSet('none', 'tasks')]
        $Expand,

        [Parameter(ParameterSetName = 'ByQuery')]
        [int]
        $TopGateRecords,

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
  
        $apiEndpoint = (Get-APApiEndpoint -ApiType 'release-releaseId') -f $ReleaseId
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