function Get-APBuildDefinition
{
    <#
    .SYNOPSIS

    Returns Azure Pipeline build definitions(s).

    .DESCRIPTION

    Returns Azure Pipeline build definitions(s) based on a filter query, if one is not provided the default will return all available definitions for the project provided.

    .PARAMETER Instance
    
    The Team Services account or TFS server.
    
    .PARAMETER Collection
    
    The value for collection should be DefaultCollection for both Team Services and TFS.

    .PARAMETER Project
    
    Project ID or project name.

    .PARAMETER DefinitionID

    The ID of the definition.

    .PARAMETER Revision

    The revision number to retrieve. If this is not specified, the latest version will be returned.

    .PARAMETER MinMetricsTime

    If specified, indicates the date from which metrics should be included.

    .PARAMETER PropertyFilters

    A comma-delimited list of properties to include in the results.

    .PARAMETER IncludeLatestBuilds

    Indicates whether to include or exclude the latest builds.

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

    https://docs.microsoft.com/en-us/rest/api/vsts/build/definitions/get?view=vsts-rest-5.0
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

        [Parameter(Mandatory)]
        [int]
        $DefinitionID,

        [Parameter(ParameterSetName = 'ByQuery')]
        [int]
        $Revision,

        [Parameter(ParameterSetName = 'ByQuery')]
        [datetime]
        $MinMetricsTime,
       
        [Parameter(ParameterSetName = 'ByQuery')]
        [string[]]
        $PropertyFilters,

        [Parameter(ParameterSetName = 'ByQuery')]
        [switch]
        $IncludeLatestBuilds,

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

        $apiEndpoint = (Get-APApiEndpoint -ApiType 'build-definitionId') -f $DefinitionID
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