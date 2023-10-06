function Update-APTestResult
{
    <#
    .SYNOPSIS

    Updated a an Azure Pipeline test result.

    .DESCRIPTION

    Updated a an Azure Pipeline test result.

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

    .PARAMETER RunId

    Id of the run to get.

    .PARAMETER TestResult

    An arrary of test results.

    Test Result Object Properties:

        AfnStripId
            AfnStripId.

        AreaUri
            Area URI of action recording.

        AutomatedTestId
            Automated test id of action recording.

        AutomatedTestName
            Automated test name of action recording.

        AutomatedTestStorage
            Automated test storage of action recording.

        AutomatedTestType
            Automated test type of action recording.

        AutomatedTestTypeId
            Automated test type identifier of action recording.

        BuildReference
            Reference to build associated with test result.

        Comment
            Comment in a test result with maxSize= 1000 chars.

        CompletedDate
            Time when test execution completed(UTC). Completed date should be greater than StartedDate.

        ComputerName
            Machine name where test executed.

        Configuration
            Reference to test configuration.

        CreatedDate
            Timestamp when test result created(UTC).

        CustomFields
            Additional properties of test result.

        DurationInMs
            Duration of test execution in milliseconds. If not provided value will be set as CompletedDate - StartedDate

        ErrorMessage
            Error message in test execution.

        FailureType
            Failure type of test result. Valid Value= (Known Issue, New Issue, Regression, Unknown, None)

        FailingSince
            Information when test results started failing.

        Id
            ID of a test result.

        IterationDetails
            Test result details of test iterations used only for Manual Testing.

        LastUpdatedBy
            Reference to identity last updated test result.

        LastUpdatedDate
            Last updated datetime of test result(UTC).

        Outcome
            Test outcome of test result. Valid values = (Unspecified, None, Passed, Failed, Inconclusive, Timeout, Aborted, Blocked, NotExecuted, Warning, Error, NotApplicable, Paused, InProgress, NotImpacted)

        Owner
            Reference to test owner.

        Priority
            Priority of test executed.

        Project
            Reference to team project.

        ReleaseReference
            Reference to release associated with test result.

        ResetCount
            ResetCount.

        ResolutionState
            Resolution state of test result.

        ResolutionStateId
            ID of resolution state.

        ResultGroupType
            Hierarchy type of the result, default value of None means its leaf node.

        Revision
            Revision number of test result.

        RunBy
            Reference to identity executed the test.

        StackTrace
            Stacktrace with maxSize= 1000 chars.

        StartedDate
            Time when test execution started(UTC).

        State
            State of test result. Type TestRunState.

        SubResults
            List of sub results inside a test result, if ResultGroupType is not None, it holds corresponding type sub results.

        TestCase
            Reference to the test executed.

        TestCaseReferenceId
            Reference ID of test used by test result. Type TestResultMetaData

        TestCaseRevision
            TestCaseRevision Number.

        TestCaseTitle
            Name of test.

        TestPlan
            Reference to test plan test case workitem is part of.

        TestPoint
            Reference to the test point executed.

        TestRun
            Reference to test run.

        TestSuite
            Reference to test suite test case workitem is part of.

        Url
            Url of test result.

    .INPUTS
    
    None, does not support pipeline.

    .OUTPUTS

    PSObject, Azure Pipelines test run(s)

    .EXAMPLE

    $testResult = @(
        @{
            testCaseTitle     = 'TestName'
            automatedTestName = "My.Test.Automation.Test.Method.TestName"
            priority          = 1
            configuration     = @{
                id = "4"
            }
            outcome           = 'Passed'
            state             = "Completed"
        }
        @{
            testCaseTitle     = 'TestName'
            automatedTestName = "My.Test.Automation.Test.Method.TestName"
            priority          = 1
            configuration     = @{
                id = "5"
            }
            outcome           = 'Failed'
            state             = "Completed"
        }
    )
    Update-APTestResult -Session $session -RunId $RunId -TestResult $testResult

    .LINK

    https://learn.microsoft.com/en-us/rest/api/azure/devops/test/results/update?view=azure-devops-rest-7.1&tabs=HTTP
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
        [string]
        $RunId,

        [Parameter(Mandatory)]
        [object[]]
        $TestResult
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
        $body = $TestResult
        $apiEndpoint = (Get-APApiEndpoint -ApiType 'test-results') -f $RunId
        $setAPUriSplat = @{
            Collection  = $Collection
            Instance    = $Instance
            Project     = $Project
            ApiVersion  = $ApiVersion
            ApiEndpoint = $apiEndpoint
        }
        [uri] $uri = Set-APUri @setAPUriSplat
        $invokeAPRestMethodSplat = @{
            Method              = 'PATCH'
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