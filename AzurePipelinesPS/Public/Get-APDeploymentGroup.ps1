function Get-APDeploymentGroup
{
    <#
    .SYNOPSIS

    Returns Azure Pipeline deployment group.

    .DESCRIPTION

    Returns Azure Pipeline deployment group based on a filter query.

    .PARAMETER Instance
    
    The Team Services account or TFS server.
    
    .PARAMETER Collection
    
    The value for collection should be DefaultCollection for both Team Services and TFS.

    .PARAMETER Project
    
    Project ID or project name.

    .PARAMETER DeploymentGroupId

    ID of the deployment group.

    .PARAMETER ActionFilter

    Get the deployment group only if this action can be performed on it.

    .PARAMETER Expand

    Include these additional details in the returned objects.    

    .PARAMETER ApiVersion
    
    Version of the api to use.

    .PARAMETER Credential

    Specifies a user account that has permission to send the request.

    .INPUTS
    

    .OUTPUTS

    PSObject, Azure Pipelines deployment group.

    .EXAMPLE

    C:\PS> Get-APDeploymentGroup -Instance 'https://myproject.visualstudio.com' -Collection 'DefaultCollection' -Project 'myFirstProject' -DeploymentGroupID 6

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

        [Parameter(Mandatory)]
        [int]
        $DeploymentGroupID,

        [Parameter(ParameterSetName = 'ByQuery')]
        [ValidateSet('manage','none','use')]
        [string]
        $ActionFilter,

        [Parameter(ParameterSetName = 'ByQuery')]
        [ValidateSet('machines','none','tags')]
        [string]
        $Expand,

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

        $apiEndpoint = (Get-APApiEndpoint -ApiType 'distributedtask-deploymentGroupId') -f $DeploymentGroupID
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