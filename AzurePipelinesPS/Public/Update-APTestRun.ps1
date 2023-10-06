function Update-APTestRun
{
    <#
    .SYNOPSIS

    Creates a an Azure Pipeline test run.

    .DESCRIPTION

    Creates a an Azure Pipeline test run.

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

    .PARAMETER BuildId

    An abstracted reference to the build that it belongs.

    .PARAMETER BuildDropLocation

    Drop location of the build used for test run.

    .PARAMETER BuildFlavor

    Flavor of the build used for test run. (E.g: Release, Debug)

    .PARAMETER BuildPlatform

    Platform of the build used for test run. (E.g.: x86, amd64)

    .PARAMETER Comment

    Comments entered by those analyzing the run.

    .PARAMETER CompletedDate

    Completed date time of the run.

    .PARAMETER Controller

    Name of the test controller used for automated run.

    .PARAMETER DeleteInProgressResults

    true to delete inProgess Results , false otherwise.

    .PARAMETER DtlAutEnvironment

    An abstracted reference to DtlAutEnvironment.

    .PARAMETER DtlEnvironment

    An abstracted reference to DtlEnvironment.

    .PARAMETER DtlEnvironmentDetails

    This is a temporary class to provide the details for the test run environment.

    .PARAMETER DueDate

    Due date and time for test run.

    .PARAMETER ErrorMessage

    Error message associated with the run.

    .PARAMETER Iteration

    The iteration in which to create the run.

    .PARAMETER LogEntries

    Log entries associated with the run. Use a comma-separated list of multiple log entry objects. { logEntry }, { logEntry }, ...

    .PARAMETER Name

    Name of the test run.

    .PARAMETER ReleaseEnvironmentUri

    URI of release environment associated with the run.

    .PARAMETER ReleaseUri

    URI of release associated with the run.

    .PARAMETER RunSummary

    Run summary for run Type = NoConfigRun.

    .PARAMETER SourceWorkflow

    SourceWorkFlow(CI/CD) of the test run.

    .PARAMETER StartedDate

    Start date time of the run.

    .PARAMETER State

    The state of the test run Below are the valid values - NotStarted, InProgress, Completed, Aborted, Waiting

    .PARAMETER Substate

    The types of sub states for test run.

    .PARAMETER Tags

    Tags to attach with the test run.

    .PARAMETER TestEnvironmentId

    ID of the test environment associated with the run.

    .PARAMETER TestSettings

    An abstracted reference to test setting resource.

    .INPUTS

    None, does not support pipeline.

    .OUTPUTS

    PSObject, Azure Pipelines test run(s)

    .EXAMPLE

    Returns AP test run for 'myFirstProject' with the id of '7'.

    $splat = @{
        RunId        = 7
        comment      = 'This is a comment'
        ErrorMessage = 'This is an error message'
        StartedDate  = '2021-03-01T00:00:00.000Z'
        Name         = 'The is a new name'
        State = 'Completed'
    }
    Update-APTestRun -Session $session @splat

    .LINK

    https://learn.microsoft.com/en-us/rest/api/azure/devops/test/runs/update?view=azure-devops-rest-7.1&tabs=HTTP
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

        [Parameter()]
        [string]
        $BuildId,

        [Parameter()]
        [string]
        $BuildDropLocation,

        [Parameter()]
        [string]
        $BuildFlavor,

        [Parameter()]
        [string]
        $BuildPlatform,

        [Parameter()]
        [string]
        $Comment,

        [Parameter()]
        [datetime]
        $CompletedDate,

        [Parameter()]
        [string]
        $Controller,

        [Parameter()]
        [bool]
        $DeleteInProgressResults,

        [Parameter()]
        [string]
        $DtlAutEnvironment,

        [Parameter()]
        [string]
        $DtlEnvironment,

        [Parameter()]
        [string]
        $DtlEnvironmentDetails,

        [Parameter()]
        [datetime]
        $DueDate,

        [Parameter()]
        [string]
        $ErrorMessage,

        [Parameter()]
        [string]
        $Iteration,

        [Parameter()]
        [object]
        $LogEntries,

        [Parameter()]
        [string]
        $Name,

        [Parameter()]
        [string]
        $ReleaseEnvironmentUri,

        [Parameter()]
        [string]
        $ReleaseUri,

        [Parameter()]
        [object]
        $RunSummary,

        [Parameter()]
        [string]
        $SourceWorkflow,

        [Parameter()]
        [datetime]
        $StartedDate,

        [Parameter()]
        [string]
        [ValidateSet("NotStarted", "InProgress", "Completed", "Aborted", "Waiting")]
        $State,

        [Parameter()]
        [string]
        $Substate,

        [Parameter()]
        [string]
        $Tags,

        [Parameter()]
        [string]
        $TestEnvironmentId,

        [Parameter()]
        [string]
        $TestSettings
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
        If ($PSBoundParameters.ContainsKey("BuildId"))
        {
            $body.build = @{
                id = $BuildId
            }
        }
        If ($PSBoundParameters.ContainsKey("BuildDropLocation"))
        {
            $body.BuildDropLocation = $BuildDropLocation
        }
        If ($PSBoundParameters.ContainsKey("BuildFlavor"))
        {
            $body.BuildFlavor = $BuildFlavor
        }
        If ($PSBoundParameters.ContainsKey("BuildPlatform"))
        {
            $body.BuildPlatform = $BuildPlatform
        }
        If ($PSBoundParameters.ContainsKey("Comment"))
        {
            $body.Comment = $Comment
        }
        If ($PSBoundParameters.ContainsKey("CompletedDate"))
        {
            $body.CompletedDate = $CompletedDate
        }
        If ($PSBoundParameters.ContainsKey("Controller"))
        {
            $body.Controller = $Controller
        }
        If ($PSBoundParameters.ContainsKey("DeleteInProgressResults"))
        {
            $body.DeleteInProgressResults = $DeleteInProgressResults
        }
        If ($PSBoundParameters.ContainsKey("DtlAutEnvironment"))
        {
            $body.DtlAutEnvironment = @{
                id = $DtlAutEnvironment
            }
        }
        If ($PSBoundParameters.ContainsKey("DtlEnvironment"))
        {
            $body.DtlEnvironment = @{
                id = $DtlEnvironment
            }
        }
        If ($PSBoundParameters.ContainsKey("DtlEnvironmentDetails"))
        {
            $body.DtlEnvironmentDetails = $DtlEnvironmentDetails
        }
        If ($PSBoundParameters.ContainsKey("DueDate"))
        {
            $body.DueDate = $DueDate
        }
        If ($PSBoundParameters.ContainsKey("ErrorMessage"))
        {
            $body.ErrorMessage = $ErrorMessage
        }
        If ($PSBoundParameters.ContainsKey("Iteration"))
        {
            $body.Iteration = $Iteration
        }
        If ($PSBoundParameters.ContainsKey("LogEntries"))
        {
            $body.LogEntries = $LogEntries
        }
        If ($PSBoundParameters.ContainsKey("Name"))
        {
            $body.Name = $Name
        }
        If ($PSBoundParameters.ContainsKey("ReleaseEnvironmentUri"))
        {
            $body.ReleaseEnvironmentUri = $ReleaseEnvironmentUri
        }
        If ($PSBoundParameters.ContainsKey("ReleaseUri"))
        {
            $body.ReleaseUri = $ReleaseUri
        }
        If ($PSBoundParameters.ContainsKey("RunSummary"))
        {
            $body.RunSummary = $RunSummary
        }
        If ($PSBoundParameters.ContainsKey("SourceWorkflow"))
        {
            $body.SourceWorkflow = $SourceWorkflow
        }
        If ($PSBoundParameters.ContainsKey("StartedDate"))
        {
            $body.StartedDate = $StartedDate
        }
        If ($PSBoundParameters.ContainsKey("State"))
        {
            $body.State = $State
        }
        If ($PSBoundParameters.ContainsKey("Substate"))
        {
            $body.Substate = $Substate
        }
        If ($PSBoundParameters.ContainsKey("Tags"))
        {
            $body.Tags = $Tags
        }
        If ($PSBoundParameters.ContainsKey("TestEnvironmentId"))
        {
            $body.TestEnvironmentId = $TestEnvironmentId
        }
        If ($PSBoundParameters.ContainsKey("TestSettings"))
        {
            $body.TestSettings = @{ 
                id = $TestSettings
            }
        }

        $apiEndpoint = (Get-APApiEndpoint -ApiType 'test-runId') -f $RunId
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