function Update-APTarget
{
    <#
    .SYNOPSIS

    Modifies an Azure Pipeline deployment group target.

    .DESCRIPTION

    Modifies an Azure Pipeline deployment group target.

    .PARAMETER Instance
    
    The Team Services account or TFS server.
    
    .PARAMETER Collection
    
    The value for collection should be DefaultCollection for both Team Services and TFS.

    .PARAMETER Project
    
    Project ID or project name.

    .PARAMETER DeploymentGroupId
    
    ID of the deployment.

    .PARAMETER Id
    
    Identifier of the deployment target.
 
    .PARAMETER Tags
    
    Tags for the deployment target.    
 
    .PARAMETER ApiVersion
    
    Version of the api to use.

    .PARAMETER Credential

    Specifies a user account that has permission to send the request.

    .INPUTS
    

    .OUTPUTS

    PSobject, An Azure Pipelines deployment group target.

    .EXAMPLE

    C:\PS> Update-APDeploymentGroup -Instance 'https://myproject.visualstudio.com' -Collection 'DefaultCollection' -Project 'myFirstProject' -DeploymentGroupID 6 -Id 30 -Tags 'myFirstTag', 'mySecondTag'

    .LINK

    https://docs.microsoft.com/en-us/rest/api/vsts/distributedtask/targets/update?view=vsts-rest-5.0
    #>
    [CmdletBinding()]
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
        [int]
        $DeploymentGroupId,

        [Parameter(Mandatory)]
        [int]
        $Id,

        [Parameter(Mandatory)]
        [string[]]
        $Tags,

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
        $body = @{
            Tags = ($Tags -join ',')
            Id   = $Description
        }
        $apiEndpoint = (Get-APApiEndpoint -ApiType 'distributedtask-targets') -f $DeploymentGroupID
        $setAPUriSplat = @{
            Collection  = $Collection
            Instance    = $Instance
            Project     = $Project
            ApiVersion  = $ApiVersion
            ApiEndpoint = $apiEndpoint
        }
        [uri] $uri = Set-APUri @setAPUriSplat
        $invokeAPRestMethodSplat = @{
            Method      = 'PATCH'
            Uri         = $uri
            Credential  = $Credential
            Body        = $body
            ContentType = 'application/json'
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