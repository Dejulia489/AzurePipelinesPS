function New-APTestRun
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

    .PARAMETER Automated

    true if test run is automated, false otherwise. By default it will be false.

    .PARAMETER Build

    An abstracted reference to the build that it belongs.

    .PARAMETER BuildDropLocation

    Drop location of the build used for test run.

    .PARAMETER BuildFlavor

    Flavor of the build used for test run. (E.g: Release, Debug)

    .PARAMETER BuildPlatform

    Platform of the build used for test run. (E.g.: x86, amd64)

    .PARAMETER BuildReference

    BuildReference of the test run.

    .PARAMETER Comment

    Comments entered by those analyzing the run.

    .PARAMETER CompleteDate

    Completed date time of the run.

    .PARAMETER ConfigurationIds

    IDs of the test configurations associated with the run.

    .PARAMETER Controller

    Name of the test controller used for automated run.

    .PARAMETER CustomTestFields

    Additional properties of test Run.

    .PARAMETER DtlAutEnvironment

    An abstracted reference to DtlAutEnvironment.

    .PARAMETER DtlTestEnvironment

    An abstracted reference to DtlTestEnvironment.

    .PARAMETER DueDate

    Due date and time for test run.

    .PARAMETER EnvironmentDetails

    This is a temporary class to provide the details for the test run environment.

    .PARAMETER ErrorMessage

    Error message associated with the run.

    .PARAMETER Filter

    Filter used for discovering the Run.

    .PARAMETER Iteration

    The iteration in which to create the run. Root iteration of the team project will be default

    .PARAMETER Name

    Name of the test run.

    .PARAMETER Owner

    Display name of the owner of the run.

    .PARAMETER PipelineId

    The id of the pipeline.

    .PARAMETER Plan

    .PARAMETER PointsIds

    .PARAMETER ReleaseEnvironmentUri

    .PARAMETER ReleaseReference

    .PARAMETER ReleaseUri

    .PARAMETER RunSummary

    .PARAMETER RunTimeout

    .PARAMETER SourceWorkflow

    .PARAMETER StartDate

    .PARAMETER State

    .PARAMETER Tags

    .PARAMETER TestConfigurationsMapping

    .PARAMETER TestEnvironmentId

    .PARAMETER TestSettings

    .PARAMETER Type

    .INPUTS

    None, does not support pipeline.

    .OUTPUTS

    PSObject, Azure Pipelines test run(s)

    .EXAMPLE

    Returns AP test run for 'myFirstProject' with the id of '7'.

    New-APTestRun -Instance 'https://dev.azure.com' -Collection 'myCollection' -Project 'myFirstProject' -Name 'My Test Run' -PlanId 6 -Automated $true

    .LINK

    https://learn.microsoft.com/en-us/rest/api/azure/devops/test/runs/create?view=azure-devops-rest-7.1&tabs=HTTP
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
        [bool]
        $Automated,

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
        $BuildReference,

        [Parameter()]
        [string]
        $Comment,

        [Parameter()]
        [string]
        $CompleteDate,

        [Parameter()]
        [int[]]
        $ConfigurationIds,

        [Parameter()]
        [string]
        $Controller,

        [Parameter()]
        [string]
        $CustomTestFields,

        [Parameter()]
        [string]
        $DtlAutEnvironment,

        [Parameter()]
        [string]
        $DtlTestEnvironment,

        [Parameter()]
        [string]
        $DueDate,

        [Parameter()]
        [string]
        $EnvironmentDetails,

        [Parameter()]
        [string]
        $ErrorMessage,

        [Parameter()]
        [string]
        $Filter,

        [Parameter()]
        [string]
        $Iteration,

        [Parameter(Mandatory)]
        [string]
        $Name,

        [Parameter()]
        [string]
        $Owner,

        [Parameter()]
        [string]
        $PipelineId,

        [Parameter()]
        [string]
        $PlanId,

        [Parameter()]
        [string[]]
        $PointsIds,

        [Parameter()]
        [string]
        $ReleaseEnvironmentUri,

        [Parameter()]
        [string]
        $ReleaseReference,

        [Parameter()]
        [string]
        $ReleaseUri,

        [Parameter()]
        [string]
        $RunSummary,

        [Parameter()]
        [string]
        $RunTimeout,

        [Parameter()]
        [string]
        $SourceWorkflow,

        [Parameter()]
        [string]
        $StartDate,

        [Parameter()]
        [string]
        $State,

        [Parameter()]
        [string]
        $Tags,

        [Parameter()]
        [string]
        $TestConfigurationsMapping,

        [Parameter()]
        [string]
        $TestEnvironmentId,

        [Parameter()]
        [string]
        $TestSettings,

        [Parameter()]
        [string]
        $Type
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
        If ($PSBoundParameters.ContainsKey("Automated"))
        {
            $body.automated = $Automated
        }
        If ($PSBoundParameters.ContainsKey("BuildId"))
        {
            $body.build = @{
                id = $BuildId
            }
        }
        If ($PSBoundParameters.ContainsKey("PlanId"))
        {
            $body.plan = @{
                id = $PlanId
            }
        }
        If ($PSBoundParameters.ContainsKey("PointId"))
        {
            $body.pointId = $PointId
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

        If ($PSBoundParameters.ContainsKey("BuildReference"))
        {
            $body.BuildReference = $BuildReference
        }

        If ($PSBoundParameters.ContainsKey("Comment"))
        {
            $body.Comment = $Comment
        }

        If ($PSBoundParameters.ContainsKey("CompleteDate"))
        {
            $body.CompleteDate = $CompleteDate
        }

        If ($PSBoundParameters.ContainsKey("ConfigurationIds"))
        {
            $body.ConfigurationIds = $ConfigurationIds
        }

        If ($PSBoundParameters.ContainsKey("Controller"))
        {
            $body.Controller = $Controller
        }

        If ($PSBoundParameters.ContainsKey("CustomTestFields"))
        {
            $body.CustomTestFields = $CustomTestFields
        }

        If ($PSBoundParameters.ContainsKey("DtlAutEnvironment"))
        {
            $body.DtlAutEnvironment = $DtlAutEnvironment
        }

        If ($PSBoundParameters.ContainsKey("DtlTestEnvironment"))
        {
            $body.DtlTestEnvironment = $DtlTestEnvironment
        }

        If ($PSBoundParameters.ContainsKey("DueDate"))
        {
            $body.DueDate = $DueDate
        }
        If ($PSBoundParameters.ContainsKey("EnvironmentDetails"))
        {
            $body.EnvironmentDetails = $EnvironmentDetails
        }
        If ($PSBoundParameters.ContainsKey("ErrorMessage"))
        {
            $body.ErrorMessage = $ErrorMessage
        }
        If ($PSBoundParameters.ContainsKey("Filter"))
        {
            $body.Filter = $Filter
        }
        If ($PSBoundParameters.ContainsKey("Iteration"))
        {
            $body.Iteration = $Iteration
        }
        If ($PSBoundParameters.ContainsKey("Name"))
        {
            $body.Name = $Name
        }
        If ($PSBoundParameters.ContainsKey("Owner"))
        {
            $body.Owner = @{
                displayName = $Owner
            }
        }
        If ($PSBoundParameters.ContainsKey("PipelineId"))
        {
            $body.PipelineReference = @{
                id = $PipelineId
            }
        }
        If ($PSBoundParameters.ContainsKey("PointsIds"))
        {
            $body.PointsIds = $PointsIds
        }
        If ($PSBoundParameters.ContainsKey("ReleaseEnvironmentUri"))
        {
            $body.ReleaseEnvironmentUri = $ReleaseEnvironmentUri
        }
        If ($PSBoundParameters.ContainsKey("ReleaseReference"))
        {
            $body.ReleaseReference = $ReleaseReference
        }
        If ($PSBoundParameters.ContainsKey("ReleaseUri"))
        {
            $body.ReleaseUri = $ReleaseUri
        }
        If ($PSBoundParameters.ContainsKey("RunSummary"))
        {
            $body.RunSummary = $RunSummary
        }
        If ($PSBoundParameters.ContainsKey("RunTimeout"))
        {
            $body.RunTimeout = $RunTimeout
        }
        If ($PSBoundParameters.ContainsKey("SourceWorkflow"))
        {
            $body.SourceWorkflow = $SourceWorkflow
        }
        If ($PSBoundParameters.ContainsKey("StartDate"))
        {
            $body.StartDate = $StartDate
        }
        If ($PSBoundParameters.ContainsKey("State"))
        {
            $body.State = $State
        }
        If ($PSBoundParameters.ContainsKey("Tags"))
        {
            $body.Tags = $Tags
        }
        If ($PSBoundParameters.ContainsKey("TestConfigurationsMapping"))
        {
            $body.TestConfigurationsMapping = $TestConfigurationsMapping
        }
        If ($PSBoundParameters.ContainsKey("TestEnvironmentId"))
        {
            $body.TestEnvironmentId = $TestEnvironmentId
        }
        If ($PSBoundParameters.ContainsKey("TestSettings"))
        {
            $body.TestSettings = $TestSettings
        }
        If ($PSBoundParameters.ContainsKey("Type"))
        {
            $body.Type = $Type
        }

        $apiEndpoint = Get-APApiEndpoint -ApiType 'test-runs'
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