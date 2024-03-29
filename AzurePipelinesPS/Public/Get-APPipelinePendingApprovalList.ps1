function Get-APPipelinePendingApprovalList
{
    <#
    .SYNOPSIS

    Returns a custom list of pending Azure Pipeline approvals filtered by build properties.

    .DESCRIPTION

    Returns a custom list of pending Azure Pipeline approvals based on a filter query.

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

    .PARAMETER BranchFilter

    A branch filter object made up of two properties, repositoryResourceName and repositoryRefName.
    The repositoryResourceName is the name of the repository resource defined in the pipeline, normally self.
    The repositoryRefName is the branch name to filter by, normally refs/heads/master.
    @{
        repositoryResourceName = 'self'
        repositoryRefName      = 'refs/heads/master'
    }

    .PARAMETER PipelineName

    The name of the pipeline to return pending approvals for.

    .PARAMETER PipelineId
    
    The id of the pipeline to return pending approvals for.

    .PARAMETER PipelineFolder

    The folder path of the pipeline(s) to return pending approvals for.

    .PARAMETER ExpandApproval

    Return the approval object with the pending approval list.
    This takes time because each approval needs to be queried.
    Useful for reviewing approval details in bulk.

    .INPUTS
    
    None, does not support pipeline.

    .OUTPUTS

    PSObject, Azure Pipelines approval(s)

    .EXAMPLE

    Returns a custom AP approval list.

    Get-APPendingApprovalList -Session $session -PipelineName 'My Pipeline Name' -BranchFilter @{ repositoryResourceName = 'self'; repositoryRefName = 'refs/heads/master' } -ExpandApproval $true -Verbose

    .LINK
    Get-APPipelineList
    https://learn.microsoft.com/en-us/rest/api/azure/devops/pipelines/pipelines/list?view=azure-devops-rest-7.1
    
    Get-APPipelineRunList
    https://learn.microsoft.com/en-us/rest/api/azure/devops/pipelines/runs/list?view=azure-devops-rest-7.1

    Get-APBuildTimeline
    https://learn.microsoft.com/en-us/rest/api/azure/devops/build/timeline/get?view=azure-devops-rest-7.1

    Get-APPipelineApproval
    https://learn.microsoft.com/en-us/rest/api/azure/devops/approvalsandchecks/approvals/get?view=azure-devops-rest-7.1&tabs=HTTP

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
        [object]
        $BranchFilter,

        [Parameter()]
        [string[]]
        $PipelineName,

        [Parameter()]
        [string[]]
        $PipelineId,

        [Parameter()]
        [string[]]
        $PipelineFolder,

        [Parameter()]
        [switch]
        $ExpandApproval
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
        $RECORD_TYPES = @(
            'Checkpoint'
            'Checkpoint.Approval'
            'Stage'
        )
        $STATUS_FILTER = @(
            'inProgress'
            'notStarted'
        )
        $splat = @{
            Instance        = $Instance
            Collection      = $Collection
            Project         = $Project
            Proxy           = $Proxy
            ProxyCredential = $ProxyCredential
            ErrorAction     = 'Stop'
        }
        If ($PersonalAccessToken)
        {
            $splat.PersonalAccessToken = $PersonalAccessToken
        }
        If ($Credential)
        {
            $splat.Credential = $Credential
        }
        $pipelines = Get-APPipelineList @splat -ApiVersion '7.1-preview.1'
        If ($PipelineName)
        {
            $pipelines = $pipelines.Where({ $PipelineName -contains $PSitem.name }) 
        }
        If ($PipelineId)
        {
            $pipelines = $pipelines.Where({ $PipelineId -contains $PSitem.id }) 
        }
        If ($PipelineFolder)
        {
            $pipelines = $pipelines.Where({ $PipelineFolder -contains $PSitem.folder }) 
        }
        $pipelineRuns = Foreach ($pipeline in $pipelines)
        {
            Get-APPipelineRunList @splat -PipelineId $pipeline.id -ApiVersion '7.1-preview.1'
        }
        $pipelineRuns = $pipelineRuns.Where({ $STATUS_FILTER -contains $PSitem.state })
        $approvalObject = Foreach ($run in $pipelineRuns)
        {
            $runDetails = Get-APPipelineRun @splat -ApiVersion '7.1-preview.1' -PipelineId $run.pipeline.id -RunId $run.id
            If ($BranchFilter)
            {
                $sourceBranch = $runDetails.resources.repositories.$($BranchFilter.repositoryResourceName).refName
                If ($BranchFilter.repositoryRefName -ne $sourceBranch)
                {
                    Continue
                }
            }
            Else
            {
                $sourceBranch = $runDetails.resources.repositories.self.refName
            }
            $timeline = Get-APBuildTimeline @Splat -ApiVersion '7.1-preview.2' -BuildId $run.id -TimelineId $run.id
            $records = $timeline.records.where({ $RECORD_TYPES -contains $PSitem.Type })
            $approvals = $records.Where( { $PSitem.type -eq 'Checkpoint.Approval' -and $PSitem.state -eq 'inprogress' } )
            foreach ($approval in $approvals)
            {
                $checkpoint = $records.Where( { $Psitem.id -eq $approval.parentId } )
                $stage = $records.Where( { $Psitem.id -eq $checkpoint.parentId } )
                If ($ExpandApproval.IsPresent)
                {
                    $approvalLookup = Get-APPipelineApproval @Splat -ApiVersion '7.1-preview.1' -ApprovalId $approval.Id
                    [pscustomObject]@{
                        pipelineName    = $run.pipeline.name
                        pipelineId      = $run.pipeline.id
                        pipelineRunId   = $run.id
                        pipelineUrl     = $run.pipeline.url
                        sourceBranch    = $sourceBranch
                        stageName       = $stage.name
                        stageIdentifier = $stage.identifier
                        approvalId      = $approval.id
                        createdDate     = $approvalLookup.createdOn
                        approval        = $approvalLookup
                    }
                }
                else
                {
                    [pscustomObject]@{
                        pipelineName    = $run.pipeline.name
                        pipelineId      = $run.pipeline.id
                        pipelineRunId   = $run.id
                        pipelineUrl     = $run.pipeline.url
                        sourceBranch    = $sourceBranch
                        stageName       = $stage.name
                        stageIdentifier = $stage.identifier
                        approvalId      = $approval.id
                    }
                }
            }
        }
        if ($approvalObject)
        {
            return $approvalObject
        }
    }
    
    end
    {
    }
}