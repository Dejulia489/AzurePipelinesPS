function Get-APVariableGroupList
{
    <#
    .SYNOPSIS

    Returns a list of Azure Pipeline variable groups.

    .DESCRIPTION

    Returns a list of Azure Pipeline variable groups based on a filter query.

    .PARAMETER Instance
    
    The Team Services account or TFS server.
    
    .PARAMETER Collection
    
    The value for collection should be DefaultCollection for both Team Services and TFS.

    .PARAMETER Project
    
    Project ID or project name.

    .PARAMETER GroupName
    
    Name of variable group.

    .PARAMETER ActionFilter
    
    Action filter for the variable group. It specifies the action which can be performed on the variable groups.

    .PARAMETER Top
    
    Number of variable groups to get.

    .PARAMETER ContinuationToken
    
    Gets the releases after the continuation token provided.

    .PARAMETER QueryOrder
    
    Gets the results in the defined order. Default is 'IdDescending'.

    .PARAMETER ApiVersion
    
    Version of the api to use.

    .PARAMETER Credential

    Specifies a user account that has permission to send the request.

    .INPUTS
    

    .OUTPUTS

    PSObject, Azure Pipelines release definition(s)

    .EXAMPLE

    C:\PS> Get-APVariableGroupList -Instance 'https://myproject.visualstudio.com' -Collection 'DefaultCollection' -Project 'myFirstProject'

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

        [Parameter(ParameterSetName = 'ByQuery')]
        [string]
        $GroupName,

        [Parameter(ParameterSetName = 'ByQuery')]
        [string]
        [ValidateSet('manage', 'none', 'use')]
        $ActionFilter,

        [Parameter(ParameterSetName = 'ByQuery')]
        [int]
        $Top,

        [Parameter(ParameterSetName = 'ByQuery')]
        [int]
        $ContinuationToken,

        [Parameter(ParameterSetName = 'ByQuery')]
        [ValidateSet('idAscending', 'idDescending')]
        [string]
        $QueryOrder,

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
        $apiEndpoint = Get-APApiEndpoint -ApiType 'distributedtask-variablegroups'
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
        $results = Invoke-APRestMethod @invokeAPRestMethodSplat | Select-Object -ExpandProperty value
        If ($results.count -eq 0)
        {
            Write-Error "[$($MyInvocation.MyCommand.Name)]: Unable to locate the variable group." -ErrorAction Stop
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