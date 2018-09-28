function Remove-APTarget
{
    <#
    .SYNOPSIS

    Deletes an Azure Pipeline deployment group.

    .DESCRIPTION

    Deletes an Azure Pipeline deployment group.

    .PARAMETER Instance
    
    The Team Services account or TFS server.
    
    .PARAMETER Collection
    
    The value for collection should be DefaultCollection for both Team Services and TFS.

    .PARAMETER Project
    
    Project ID or project name.

    .PARAMETER DeploymentGroupId
    
    ID of the deployment group in which deployment target is deleted.

    .PARAMETER TargetId
    
    ID of the deployment target to delete.  
 
    .PARAMETER ApiVersion
    
    Version of the api to use.

    .PARAMETER Credential

    Specifies a user account that has permission to send the request.

    .INPUTS
    

    .OUTPUTS

    None, Remove-APTarget returns nothing.

    .EXAMPLE

    C:\PS> Remove-APTarget -Instance 'https://myproject.visualstudio.com' -Collection 'DefaultCollection' -Project 'myFirstProject' -DeploymentGroupID 6 -TargetId 25

    .LINK

    https://docs.microsoft.com/en-us/rest/api/vsts/distributedtask/targets/delete?view=vsts-rest-5.0
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

        [Parameter(Mandatory)]
        [string]
        $Project,

        [Parameter(Mandatory)]
        [int]
        $DeploymentGroupId,

        [Parameter(Mandatory)]
        [int]
        $TargetId,

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
        $apiEndpoint = (Get-APApiEndpoint -ApiType 'distributedtask-targetId') -f $DeploymentGroupID, $TargetId
        $setAPUriSplat = @{
            Collection  = $Collection
            Instance    = $Instance
            Project     = $Project
            ApiVersion  = $ApiVersion
            ApiEndpoint = $apiEndpoint
        }
        [uri] $uri = Set-APUri @setAPUriSplat
        $invokeAPRestMethodSplat = @{
            Method      = 'DELETE'
            Uri         = $uri
            Credential  = $Credential
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