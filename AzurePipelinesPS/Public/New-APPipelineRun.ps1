function New-APPipelineRun {
  <#
    .SYNOPSIS

    Creates a new pipeline run by pipeline name.

    .DESCRIPTION

    Creates a new pipeline run by pipeline name.
    The name can be returned using Get-APPipelineList.

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

    .PARAMETER Name

    The name of the pipeline to run.

    .PARAMETER Resources

    The resources the run requires.
    https://learn.microsoft.com/en-us/rest/api/azure/devops/pipelines/runs/run-pipeline?view=azure-devops-rest-6.0#runresourcesparameters

    .PARAMETER StagesToSkip

    The stages to skip.

    .PARAMETER PipelineVersion

    The version of the pipeline to queue.

    .PARAMETER TemplateParameters

    Runtime parameters to pass to the pipeline.

    .PARAMETER Variables

    Pipeline variables.

    .PARAMETER Wait

    Switch, wait for timeline record status.

    .PARAMETER RecordName

    The name of the timeline record.

    .PARAMETER RecordType

    The type of the timeline record.

    .PARAMETER RecordState

    The state of the timeline record.

    .PARAMETER Approval

    Switch, provide environment approval.

    .PARAMETER ApprovalStageIdentifier

    The name of the stage that the approval is for.

    .PARAMETER ApprovalStatus

    The status to provide to the environment approval.

    .PARAMETER ApprovalComment

    The comment to provide to the environment approval.

    .PARAMETER Timeout

    Timeout threshold in seconds.

    .PARAMETER PollingInterval

    The number of seconds to wait before checking the status of the build, defaults to 1.

    .INPUTS

    None, does not support pipeline.

    .OUTPUTS

    None

    .EXAMPLE

    $splat = @{
        Session                 = $session
        Name                    = 'Approval'
        Wait                    = $true
        RecordName              = 'Checkpoint.Approval'
        RecordType              = 'Checkpoint.Approval'
        RecordState             = 'inProgress'
        Approval                = $true
        ApprovalStatus          = 'approved'
        ApprovalStageIdentifier = 'QA_Deployment'
        Resources               = @{}
        TemplateParameters      = @{}
        StagesToSkip            = @()
        Variables               = @{}
        Verbose                 = $true
    }

    New-APPipelineRun @splat

    .LINK

    https://docs.microsoft.com/en-us/rest/api/azure/devops/pipelines/runs/run%20pipeline?view=azure-devops-rest-6.0
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

    [Parameter(Mandatory)]
    [string]
    $Name,

    [Parameter()]
    [object]
    $Resources,

    [Parameter()]
    [string[]]
    $StagesToSkip,

    [Parameter()]
    [int]
    $PipelineVersion,

    [Parameter()]
    [hashtable]
    $TemplateParameters,

    [Parameter()]
    [hashtable]
    $Variables,

    [Parameter()]
    [switch]
    $Wait,

    [Parameter()]
    [string]
    $RecordName,

    [Parameter()]
    [string]
    $RecordType,

    [Parameter()]
    [ValidateSet('completed', 'inProgress', 'pending')]
    [string]
    $RecordState,

    [Parameter()]
    [switch]
    $Approval,

    [Parameter()]
    [string]
    $ApprovalStageIdentifier,

    [Parameter()]
    [ValidateSet('approved', 'rejected')]
    [string]
    $ApprovalStatus,

    [Parameter()]
    [string]
    $ApprovalComment,

    [Parameter()]
    [int]
    $Timeout = 300,

    [Parameter()]
    [int]
    $PollingInterval = 1
  )

  begin {
    If ($PSCmdlet.ParameterSetName -eq 'BySession') {
      $currentSession = $Session | Get-APSession
      If ($currentSession) {
        $Instance = $currentSession.Instance
        $Collection = $currentSession.Collection
        $Project = $currentSession.Project
        $PersonalAccessToken = $currentSession.PersonalAccessToken
        $Credential = $currentSession.Credential
        $Proxy = $currentSession.Proxy
        $ProxyCredential = $currentSession.ProxyCredential
        If ($currentSession.Version) {
          $ApiVersion = (Get-APApiVersion -Version $currentSession.Version)
        }
        else {
          $ApiVersion = $currentSession.ApiVersion
        }
      }
    }
  }
  process {
    $splat = @{
      Collection = $Collection
      Instance   = $Instance
      Project    = $Project
      ApiVersion = $ApiVersion
    }
    If ($Credential) {
      $splat.Credential = $Credential
    }
    If ($PersonalAccessToken) {
      $splat.PersonalAccessToken = $PersonalAccessToken
    }
    If ($Proxy) {
      $splat.Proxy = $Proxy
    }
    If ($ProxyCredential) {
      $splat.ProxyCredential = $ProxyCredential
    }
    $pipelineDefinition = Get-APBuildDefinitionList @Splat -Name $Name
    $run = Invoke-APPipeline @splat -PipelineId $pipelineDefinition.id -PipelineVersion $PipelineVersion -TemplateParameters $TemplateParameters -Resources $Resources -Variables $Variables -StagesToSkip $StagesToSkip

    If ($Wait.IsPresent) {
      $record = Wait-APTimelineRecord @Splat -RunId $run.Id -RecordName $RecordName -RecordType $RecordType -RecordState $RecordState -PollingInterval $PollingInterval -Timeout $Timeout
    }

    If ($Wait.IsPresent -and $Approval.IsPresent) {
      $approvals = Get-APPipelinePendingApprovalList @splat -Definitions $pipelineDefinition.Id -BuildIds $run.Id
      $_approval = $approvals.Where( { $PSitem.stageIdentifier -eq $ApprovalStageIdentifier } )
      If ($record.Id -notcontains $_approval.approvalId) {
        Write-Error "[$($MyInvocation.MyCommand.Name)]: The approval ids $($_approval.approvalId) do not contain the record id $($record.Id). Verify the stage identifier." -ErrorAction 'Stop'
      }

      $approvalSplat = @{
        Instance            = $Instance
        Collection          = $Collection
        Project             = $Project
        Proxy               = $Proxy
        ProxyCredential     = $ProxyCredential
        PersonalAccessToken = $PersonalAccessToken
        ApiVersion          = '6.1-preview.1'
        ApprovalId          = $_approval.approvalId
        Status              = $ApprovalStatus
        Comment             = $ApprovalComment
      }
      Update-APPipelineApproval @approvalSplat
    }
  }
  end {
  }
}