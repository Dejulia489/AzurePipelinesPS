function Get-APDeploymentGroupList
{
    <#
    .SYNOPSIS

    Returns a list of Azure Pipeline deployment group(s).

    .DESCRIPTION

    Returns a list of Azure Pipeline deployment group(s) based on a filter query.

    .PARAMETER Instance
    
    The Team Services account or TFS server.
    
    .PARAMETER Collection
    
    The value for collection should be DefaultCollection for both Team Services and TFS.

    .PARAMETER Project
    
    Project ID or project name.

    .PARAMETER Name

    Name of the deployment group.

    .PARAMETER ActionFilter

    Get the deployment group only if this action can be performed on it.

    .PARAMETER Expand

    Include these additional details in the returned objects.

    .PARAMETER ContinuationToken

    Get deployment groups with names greater than this continuationToken lexicographically.

    .PARAMETER Top

    Maximum number of deployment groups to return. Default is 1000.

    .PARAMETER Ids

    Comma separated list of IDs of the deployment groups.

    .PARAMETER ApiVersion
    
    Version of the api to use.

    .PARAMETER Credential

    Specifies a user account that has permission to send the request.

    .INPUTS
    

    .OUTPUTS

    PSObject, Azure Pipelines deployment group.

    .EXAMPLE

    C:\PS> Get-APDeploymentGroupList -Instance 'https://myproject.visualstudio.com' -Collection 'DefaultCollection' -Project 'myFirstProject' -Name Dev

    .LINK

    https://docs.microsoft.com/en-us/rest/api/vsts/distributedtask/deploymentgroups/get?view=vsts-rest-5.0
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
        $Name,

        [Parameter(ParameterSetName = 'ByQuery')]
        [ValidateSet('manage','none','use')]
        [string]
        $ActionFilter,

        [Parameter(ParameterSetName = 'ByQuery')]
        [ValidateSet('machines','none','tags')]
        [string]
        $Expand,

        [Parameter(ParameterSetName = 'ByQuery')]
        [int]
        $Top,

        [Parameter(ParameterSetName = 'ByQuery')]
        [int[]]
        $Ids,

        [Parameter(ParameterSetName = 'ByQuery')]
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

        $apiEndpoint = Get-APApiEndpoint -ApiType 'distributedtask-deploymentgroups'
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