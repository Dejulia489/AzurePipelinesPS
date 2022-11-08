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
    
    Personal access token used to authenticate that has been converted to a secure string. 
    It is recomended to uses an Azure Pipelines PS session to pass the personal access token parameter among funcitons, See New-APSession.
    https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=vsts
    
    .PARAMETER Credential

    Specifies a user account that has permission to send the request.

    .PARAMETER Proxy
    
    Use a proxy server for the request, rather than connecting directly to the Internet resource. Enter the URI of a network proxy server.

    .PARAMETER ProxyCredential
    
    Specifie a user account that has permission to use the proxy server that is specified by the -Proxy parameter. The default is the current user.

    .PARAMETER Session

    Azure DevOps PS session, created by New-APSession.

    .PARAMETER DeploymentGroupId

    ID of the deployment group.

    .PARAMETER Tags

    Get only the deployment targets that contain all these comma separted list of tags.

    .PARAMETER Name

    Name pattern of the deployment targets to return.

    .PARAMETER PartialNameMatch

    When set to true, treats name as pattern. else treats it as absolute match. Default is false.

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
    
    None, does not support pipeline.

    .OUTPUTS

    PSObject, Azure Pipelines deployment group.

    .EXAMPLE

    Returns AP target list with the deployment group id of '6 for 'myFirstProject'.

    Get-APTargetList -Instance 'https://dev.azure.com' -Collection 'myCollection' -Project 'myFirstProject' -DeploymentGroupID 6

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

        [Parameter(ParameterSetName = 'ByPersonalAccessToken')]
        [Parameter(ParameterSetName = 'ByCredential')]
        [string]
        $Proxy,

        [Parameter(ParameterSetName = 'ByPersonalAccessToken')]
        [Parameter(ParameterSetName = 'ByCredential')]
        [pscredential]
        $ProxyCredential,

        [Parameter(Mandatory,
            ParameterSetName = 'BySession')]
        [ArgumentCompleter( {
                param ( $commandName,
                    $parameterName,
                    $wordToComplete,
                    $commandAst,
                    $fakeBoundParameters )
                $possibleValues = Get-APSession | Select-Object -ExpandProperty SessionNAme
                $possibleValues.Where( { $PSitem -match $wordToComplete })
            })]
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
                $PersonalAccessToken = $currentSession.PersonalAccessToken
                $Credential = $currentSession.Credential
                $Proxy = $currentSession.Proxy
                $ProxyCredential = $currentSession.ProxyCredential
                If ($currentSession.Version)
                {
                    $ApiVersion = (Get-APApiVersion -Version $currentSession.Version)
                }
                else
                {
                    $ApiVersion = $currentSession.ApiVersion
                }
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
        $invokeAPWebRequestSplat = @{
            Method              = 'GET'
            Uri                 = $uri
            Credential          = $Credential
            PersonalAccessToken = $PersonalAccessToken
            Proxy               = $Proxy
            ProxyCredential     = $ProxyCredential
        }
        $results = Invoke-APWebRequest @invokeAPWebRequestSplat
        If ($results.continuationToken -and (-not($PSBoundParameters.ContainsKey('Top'))))
        {
            $results.value
            $null = $PSBoundParameters.Remove('ContinuationToken')
            Get-APTargetList @PSBoundParameters -ContinuationToken $results.continuationToken
        }
        elseIf ($results.value.count -eq 0)
        {
            return
        }
        elseIf ($results.value)
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