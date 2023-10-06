function New-APTestSuite
{
    <#
    .SYNOPSIS

    Creates a an Azure Pipeline test suite.

    .DESCRIPTION

    Creates a an Azure Pipeline test suite.

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

    .PARAMETER DefaultConfigurations

    Default configurations for test cases in this suite.

    .PARAMETER DefaultTesters

    Default testers for test cases in this suite.

    .PARAMETER InheritDefaultConfigurations

    Default configurations for test cases in this suite.

    .PARAMETER Name

    Name of the test suite.

    .PARAMETER ParentSuiteId

    Id of the parent test suite.

    .PARAMETER QueryString

    Query string for test cases in this suite.

    .PARAMETER RequirementId

    Id of the requirement that is linked to test cases in this suite.

    .PARAMETER SuiteType

    Type of the test suite to create.

    .INPUTS

    None, does not support pipeline.

    .OUTPUTS

    PSObject, Azure Pipelines test run(s)

    .EXAMPLE

    Returns AP test run for 'myFirstProject' with the id of '7'.

    New-APTestRun -Instance 'https://dev.azure.com' -Collection 'myCollection' -Project 'myFirstProject' -Name 'My Test Run' -PlanId 6 -Automated $true

    .LINK

    https://learn.microsoft.com/en-us/rest/api/azure/devops/testplan/test-suites/create?view=azure-devops-rest-7.1&tabs=HTTP
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
        [string]
        $PlanId,

        [Parameter()]
        [object[]]
        $DefaultConfigurations,

        [Parameter()]
        [string]
        $DefaultTesters,

        [Parameter()]
        [boolean]
        $InheritDefaultConfigurations,

        [Parameter()]
        [string]
        $Name,

        [Parameter()]
        [string]
        $ParentSuiteId,

        [Parameter()]
        [string]
        $QueryString,

        [Parameter()]
        [string]
        $RequirementId,

        [Parameter()]
        [ValidateSet("dynamicTestSuite", "staticTestSuite", "requirementTestSuite", "none")]
        [string]
        $SuiteType
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
        $body = @{
            name = $Name
        }
        If ($PSBoundParameters.ContainsKey("DefaultConfigurations"))
        {
            $body.DefaultConfigurations = $DefaultConfigurations
        }
        If ($PSBoundParameters.ContainsKey("DefaultTesters"))
        {
            $body.DefaultTesters = $DefaultTesters
        }
        If ($PSBoundParameters.ContainsKey("InheritDefaultConfigurations"))
        {
            $body.InheritDefaultConfigurations = $InheritDefaultConfigurations
        }
        If ($PSBoundParameters.ContainsKey("ParentSuiteId"))
        {
            $body.ParentSuite = @{
                id = $ParentSuiteId
            }
        }
        If ($PSBoundParameters.ContainsKey("QueryString"))
        {
            $body.QueryString = $QueryString
        }
        If ($PSBoundParameters.ContainsKey("RequirementId"))
        {
            $body.RequirementId = $RequirementId
        }
        If ($PSBoundParameters.ContainsKey("SuiteType"))
        {
            $body.SuiteType = $SuiteType
        }
        $apiEndpoint = (Get-APApiEndpoint -ApiType 'testplan-suites') -f $PlanId
        $setAPUriSplat = @{
            Collection  = $Collection
            Instance    = $Instance
            Project     = $Project
            ApiVersion  = $ApiVersion
            ApiEndpoint = $apiEndpoint
        }
        [uri] $uri = Set-APUri @setAPUriSplat
        $invokeAPRestMethodSplat = @{
            Method              = 'POST'
            Uri                 = $uri
            Credential          = $Credential
            PersonalAccessToken = $PersonalAccessToken
            Proxy               = $Proxy
            ProxyCredential     = $ProxyCredential
            Body                = $body
            ContentType         = 'application/json'
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