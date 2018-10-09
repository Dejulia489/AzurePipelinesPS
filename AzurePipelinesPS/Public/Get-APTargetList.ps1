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
    
    For Azure DevOps the value for collection should be the name of your orginization. 
    For both Team Services and TFS The value should be DefaultCollection unless another collection has been created.

    .PARAMETER Project
    
    Project ID or project name.

    .PARAMETER ApiVersion
    
    Version of the api to use.

    .PARAMETER PersonalAccessToken
    
    Personal access token used to authenticate. https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=vsts

    .PARAMETER Credential

    Specifies a user account that has permission to send the request.

    .PARAMETER Session

    Azure DevOps PS session, created by New-APSession.

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

    .INPUTS
    

    .OUTPUTS

    PSObject, Azure Pipelines deployment group.

    .EXAMPLE

    C:\PS> Get-APTargetList -Instance 'https://myproject.visualstudio.com' -Collection 'DefaultCollection' -Project 'myFirstProject' -DeploymentGroupID 6

    .LINK

    https://docs.microsoft.com/en-us/rest/api/vsts/distributedtask/targets/list?view=vsts-rest-5.0
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
        
        [Parameter(Mandatory)]
        [int]
        $DeploymentGroupID,

        [Parameter()]
        [string[]]
        $Tags,

        [Parameter()]
        [string]
        $Name,

        [Parameter()]
        [bool]
        $PartialNameMatch,

        [Parameter()]
        [ValidateSet('assignedRequest', 'capabilities', 'lastCompletedRequest', 'none')]
        [string]
        $Expand,
        
        [Parameter()]
        [ValidateSet('all', 'offline', 'online')]
        [string]
        $AgentStatus,

        [Parameter()]
        [ValidateSet('all', 'failed', 'neverDeployed', 'passed')]
        [string]
        $AgentJobResult,

        [Parameter()]
        [string]
        $ContinuationToken,

        [Parameter()]
        [int]
        $Top,

        [Parameter()]
        [bool]
        $Enabled
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