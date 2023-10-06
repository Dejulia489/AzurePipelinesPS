function Update-APTestPoint
{
    <#
    .SYNOPSIS

    Updates an Azure Pipeline test point.

    .DESCRIPTION

    Updates an Azure Pipeline test point based on the plan id, suite id and point id.
    The plan id can be retrieved by using Get-APTestPlanList.
    The suite id can be retrieved by using Get-APTestSuiteListByPlanId.
    The point id can be retrieved by using Get-APTestSuiteTestPointList.

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

    .PARAMETER PlanId

    Id of the test plan.

    .PARAMETER SuiteId

    Id of the test suite.

    .PARAMETER PointId

    Id of the test point.

    .PARAMETER Outcome

    The outcome of the test point. Valid values are: aborted, blocked, error, failed, inProgress, inconclusive, maxValue, none, notApplicable, notExecuted, notImpacted, passed, paused, timeout, unspecified, warning.

    .PARAMETER ResetToActive

    Reset the test point to active.

    .PARAMETER TesterDisplayName

    The display name of the tester.

    .INPUTS

    None, does not support pipeline.

    .OUTPUTS

    None, Update-APTestPoint returns Azure Pipelines release definition.

    .EXAMPLE

    Updates AP release with the release id of '5' with the $template.

    Update-APTestPoint -Instance 'https://dev.azure.com' -Collection 'myCollection' -Project 'myFirstProject' -PlanId 5 -SuiteId 8 -PointId 10

    .LINK

    https://learn.microsoft.com/en-us/rest/api/azure/devops/test/points/update?view=azure-devops-rest-7.1&tabs=HTTP
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
        $PlanId,

        [Parameter(Mandatory)]
        [int]
        $SuiteId,

        [Parameter(Mandatory)]
        [string]
        $PointId,

        [Parameter()]
        [ValidateSet("aborted", "blocked", "error", "failed", "inProgress", "inconclusive", "maxValue", "none", "notApplicable", "notExecuted", "notImpacted", "passed", "paused", "timeout", "unspecified", "warning")]
        [string]
        $Outcome,

        [Parameter()]
        [boolean]
        $ResetToActive,

        [Parameter()]
        [string]
        $TesterDisplayName
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
        $body = @{}
        If ($PSBoundParameters.ContainsKey('Outcome'))
        {
            $body.outcome = $Outcome
        }
        If ($PSBoundParameters.ContainsKey('ResetToActive'))
        {
            $body.resetToActive = $ResetToActive
        }
        If ($PSBoundParameters.ContainsKey('TesterDisplayName'))
        {
            $body.tester = @{
                displayName = $TesterDisplayName
            }
        }
        $apiEndpoint = (Get-APApiEndpoint -ApiType 'test-pointIds') -f $PlanId, $SuiteId, $PointId
        $setAPUriSplat = @{
            Collection  = $Collection
            Instance    = $Instance
            Project     = $Project
            ApiVersion  = $ApiVersion
            ApiEndpoint = $apiEndpoint
        }
        [uri] $uri = Set-APUri @setAPUriSplat
        $invokeAPRestMethodSplat = @{
            ContentType         = 'application/json'
            Body                = $body
            Method              = 'PATCH'
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