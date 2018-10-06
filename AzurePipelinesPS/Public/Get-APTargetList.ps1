function Get-APTargetList
{
    <#
    .SYNOPSIS

    Returns a list of Azure Pipeline deployment group targets.

    .DESCRIPTION

    Returns a list of Azure Pipeline deployment group targets based on a filter query.

    .PARAMETER Instance
    
    The Team Services account or TFS server.
    
    .PARAMETER Collection
    
    The value for collection should be DefaultCollection for both Team Services and TFS.

    .PARAMETER Project
    
    Project ID or project name.

    .PARAMETER DeploymentGroupId

    ID of the deployment group.

    .PARAMETER Tags

    Get only the deployment targets that contain all these comma separted list of tags.

    .PARAMETER Name

    Name pattern of the deployment targets to return.

    .PARAMETER PartialNameMatch

    When set to true, treats name as pattern. Else treats it as absolute match. Default is false.

    .PARAMETER Expand

    Include these additional details in the returned objects. 
    
    .PARAMETER AgentStatus
    
    Get only deployment targets that have this status.
    
    .PARAMETER AgentJobResult

    Get only deployment targets that have this last job result.

    .PARAMETER ContinuationToken

    Get deployment targets with names greater than this continuationToken lexicographically.

    .PARAMETER Top

    Maximum number of deployment targets to return. Default is 1000.

    .PARAMETER Enabled

    Get only deployment targets that are enabled or disabled. Default is 'null' which returns all the targets.

    .PARAMETER ApiVersion
    
    Version of the api to use.

    .PARAMETER Credential

    Specifies a user account that has permission to send the request.

    .INPUTS
    

    .OUTPUTS

    PSObject, Azure Pipelines deployment group.

    .EXAMPLE

    C:\PS> Get-APTargetList -Instance 'https://myproject.visualstudio.com' -Collection 'DefaultCollection' -Project 'myFirstProject' -DeploymentGroupID 6

    .LINK

    https://docs.microsoft.com/en-us/rest/api/vsts/distributedtask/targets/list?view=vsts-rest-5.0
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
        $DeploymentGroupID,

        [Parameter(ParameterSetName = 'ByQuery')]
        [string[]]
        $Tags,

        [Parameter(ParameterSetName = 'ByQuery')]
        [string]
        $Name,

        [Parameter(ParameterSetName = 'ByQuery')]
        [bool]
        $PartialNameMatch,

        [Parameter(ParameterSetName = 'ByQuery')]
        [ValidateSet('assignedRequest', 'capabilities', 'lastCompletedRequest', 'none')]
        [string]
        $Expand,
        
        [Parameter(ParameterSetName = 'ByQuery')]
        [ValidateSet('all', 'offline', 'online')]
        [string]
        $AgentStatus,

        [Parameter(ParameterSetName = 'ByQuery')]
        [ValidateSet('all', 'failed', 'neverDeployed', 'passed')]
        [string]
        $AgentJobResult,

        [Parameter(ParameterSetName = 'ByQuery')]
        [string]
        $ContinuationToken,

        [Parameter(ParameterSetName = 'ByQuery')]
        [int]
        $Top,

        [Parameter(ParameterSetName = 'ByQuery')]
        [bool]
        $Enabled,        

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

        $apiEndpoint = (Get-APApiEndpoint -ApiType 'distributedtask-targets') -f $DeploymentGroupID
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