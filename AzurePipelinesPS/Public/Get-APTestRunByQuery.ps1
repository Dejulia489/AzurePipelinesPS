function Get-APTestRunByQuery
{
    <#
    .SYNOPSIS

    Returns an Azure Pipeline test run based on a query.

    .DESCRIPTION

    Returns an Azure Pipeline test run based on a query.

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

    .PARAMETER MaxLastUpdatedDate

    Id of the test plan to get.

    .PARAMETER MinLastUpdatedDate

    Minimum Last Modified Date of run to be queried (Mandatory).

    .PARAMETER Top

    Number of runs to be queried. Limit is 100

    .PARAMETER BranchName

    Source Branch name of the Runs to be queried.

    .PARAMETER BuildDefIds

    Build Definition Ids of the Runs to be queried, comma separated list of valid ids (limit no. of ids 10).

    .PARAMETER BuildIds

    Build Ids of the Runs to be queried, comma separated list of valid ids (limit no. of ids 10).

    .PARAMETER ContinuationToken

    continuationToken received from previous batch or null for first batch. It is not supposed to be created (or altered, if received from last batch) by user.

    .PARAMETER IsAutomated

    Automation type of the Runs to be queried.

    .PARAMETER PlanIds

    Plan Ids of the Runs to be queried, comma separated list of valid ids (limit no. of ids 10).

    .PARAMETER PublishContext

    PublishContext of the Runs to be queried.

    .PARAMETER ReleaseDefIds

    Release Definition Ids of the Runs to be queried, comma separated list of valid ids (limit no. of ids 10).


    .PARAMETER ReleaseEnvDefIds

    Release Environment Definition Ids of the Runs to be queried, comma separated list of valid ids (limit no. of ids 10).

    .PARAMETER ReleaseEnvIds

    Release Environment Ids of the Runs to be queried, comma separated list of valid ids (limit no. of ids 10).

    .PARAMETER ReleaseIds

    Release Ids of the Runs to be queried, comma separated list of valid ids (limit no. of ids 10).

    .PARAMETER RunTitle

    Run Title of the Runs to be queried.

    .PARAMETER State

    Current state of the Runs to be queried.

    .INPUTS

    None, does not support pipeline.

    .OUTPUTS

    PSObject, Azure Pipelines test plan(s)

    .EXAMPLE

    Returns AP test plan list for 'myFirstProject' and the plan id of '8'.

    Get-APTestRunByQuery -Instance 'https://dev.azure.com' -Collection 'myCollection' -Project 'myFirstProject' -PlanId 8

    .LINK

    https://learn.microsoft.com/en-us/rest/api/azure/devops/test/runs/query?view=azure-devops-rest-7.1
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

        [Parameter()]
        [datetime]
        $MaxLastUpdatedDate,

        [Parameter()]
        [datetime]
        $MinLastUpdatedDate,

        [Parameter()]
        [int]
        $Top,

        [Parameter()]
        [string]
        $BranchName,

        [Parameter()]
        [string[]]
        $BuildDefIds,

        [Parameter()]
        [string[]]
        $BuildIds,

        [Parameter()]
        [string]
        $ContinuationToken,

        [Parameter()]
        [bool]
        $IsAutomated,

        [Parameter()]
        [string[]]
        $PlanIds,

        [Parameter()]
        [ValidateSet("all", "build", "release")]
        [string]
        $PublishContext,

        [Parameter()]
        [string[]]
        $ReleaseDefIds,

        [Parameter()]
        [string[]]
        $ReleaseEnvDefIds,

        [Parameter()]
        [string[]]
        $ReleaseEnvIds,

        [Parameter()]
        [string[]]
        $ReleaseIds,

        [Parameter()]
        [string]
        $RunTitle,

        [Parameter()]
        [ValidateSet("aborted", "completed", "inProgress", "needsInvestigation", "notStarted", "unspecified", "waiting")]
        [string]
        $State
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
        $apiEndpoint = Get-APApiEndpoint -ApiType 'test-runs'
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
            Method              = 'GET'
            Uri                 = $uri
            Credential          = $Credential
            PersonalAccessToken = $PersonalAccessToken
            Proxy               = $Proxy
            ProxyCredential     = $ProxyCredential
        }
        $results = Invoke-APRestMethod @invokeAPRestMethodSplat
        If ($results.continuationToken -and (-not($PSBoundParameters.ContainsKey('Top'))))
        {
            $results.value
            $null = $PSBoundParameters.Remove('ContinuationToken')
            Get-APTestRunByQuery @PSBoundParameters -ContinuationToken $results.continuationToken
        }
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