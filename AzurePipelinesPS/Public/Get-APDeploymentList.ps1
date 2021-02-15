function Get-APDeploymentList
{
    <#
    .SYNOPSIS

    Returns a list of Azure Pipeline deployments.

    .DESCRIPTION

    Returns a list of Azure Pipeline deployments based on a filter query.

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

    .PARAMETER MaxStartedTime
    
    Deployments with max started time by will be returned.

    .PARAMETER MinStartedTime 

    Deployments with min started time by will be returned.

    .PARAMETER CreatedFor
    
    Deployments with created for by will be returned.

    .PARAMETER ContinuationToken
    
    Gets the releases after the continuation token provided.

    .PARAMETER Top
    
    Number of deployments to return. Default is 50.

    .PARAMETER QueryOrder
    
    The order in which to return the query in.

    .PARAMETER LatestAttemptsOnly

    The latest attempt for stage will be returned.

    .PARAMETER OperationStatus
    
    Deployments with the operation status by will be returned.

    .PARAMETER DeploymentStatus
    
    Deployments with deployment status by will be returned.

    .PARAMETER MaxModifiedTime
    
    Deployments with max modified time by will be returned.

    .PARAMETER MinModifiedTime
    
    Deployments with min modified time by will be returned.

    .PARAMETER CreatedBy

    Deployments with given created by will be returned.
    
    .PARAMETER DefinitionEnvironmentId
    
    Undefined, see link for documentation

    .PARAMETER DefinitionId
    
    Deployments from this release definition Id.

    .PARAMETER SourceBranch
    
    Deployments with given source branch will be returned.

    .INPUTS
    
    None, does not support pipeline.

    .OUTPUTS

    PSObject, Azure Pipelines release(s)

    .EXAMPLE

    Returns AP release list for 'myFirstProject'.

    Get-APDeploymentList -Instance 'https://dev.azure.com' -Collection 'myCollection' -Project 'myFirstProject'

    .LINK

    https://docs.microsoft.com/en-us/rest/api/vsts/release/releases/list?view=vsts-rest-5.0
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
        [object]
        $Session,
        
        [Parameter()]
        [string]
        $MaxStartedTime,

        [Parameter()]
        [string]
        $MinStartedTime,

        [Parameter()]
        [string]
        $CreatedFor,

        [Parameter()]
        [int]
        $ContinuationToken,

        [Parameter()]
        [int]
        $Top,

        [Parameter()]
        [string]
        [ValidateSet('ascending', 'descending')]
        $QueryOrder,

        [Parameter()]
        [bool]
        $LatestAttemptsOnly,

        [Parameter()]
        [ValidateSet('all', 'approved', 'canceled', 'deferred', 'gateFailed', 'manualInterventionPending', 'pending', 'phaseCanceled', 'phaseFailed', 'phaseInProgress', 'phasePartiallySucceeded', 'phasedSucceeded', 'queued', 'queuedForAgent', 'queuedForPipeline', 'rejected', 'scheduled', 'undefined')]
        [string]
        $OperationStatus,

        [Parameter()]
        [ValidateSet('all', 'failed', 'inProgress', 'notDeployed', 'partiallySucceeded', 'succeeded', 'undefined')]
        [string]
        $DeploymentStatus,

        [Parameter()]
        [string]
        $MaxModifiedTime,

        [Parameter()]
        [string]
        $MinModifiedTime,

        [Parameter()]
        [string]
        $CreatedBy,

        [Parameter()]
        [int]
        $DefinitionEnvironmentId,

        [Parameter()]
        [int]
        $DefinitionId,

        [Parameter()]
        [string]
        $SourceBranch
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
        $apiEndpoint = Get-APApiEndpoint -ApiType 'release-deployments'
        $queryParameters = Set-APQueryParameters -InputObject $PSBoundParameters
        $setAPUriSplat = @{
            Collection          = $Collection
            Instance            = $Instance
            Project             = $Project
            ApiVersion          = $ApiVersion
            ApiEndpoint         = $apiEndpoint
            Query               = $queryParameters
            ApiSubDomainSwitch = 'vsrm'
        }
        [uri] $uri = Set-APUri @setAPUriSplat
        $invokeAPRestMethodSplat = @{
            Method              = 'GET'
            Uri                 = $uri
            Credential          = $Credential
            PersonalAccessToken = $PersonalAccessToken
            Proxy               = $Proxy
            ProxyCredential     = $ProxyCredential
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