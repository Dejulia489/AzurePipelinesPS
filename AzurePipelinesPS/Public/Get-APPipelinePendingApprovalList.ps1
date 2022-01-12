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

    .PARAMETER BranchName

    The name of the builds source branch. Ex: 'refs/heads/master'

    .PARAMETER Definitions

    The id of the build definition.

    .PARAMETER BuildIds
    
    The ids of the builds to return pending approvals for.

    .PARAMETER ExpandApproval

    Return the approval object with the pending approval list.
    This takes time because each approval needs to be queried.
    Useful for review approval details in bulk.

    .INPUTS
    
    None, does not support pipeline.

    .OUTPUTS

    PSObject, Azure Pipelines approval(s)

    .EXAMPLE

    Returns a custom AP approval list.

    Get-APPipelineApprovalList -Instance 'https://dev.azure.com' -Collection 'myCollection' -Project 'myFirstProject' -ApiVersion 5.0-preview -ApprovalId 4eg5aavx-1000-4333-ba70-6457d5b15f0e

    .LINK

    https://docs.microsoft.com/en-us/rest/api/azure/devops/approvalsandchecks/approvals/query?view=azure-devops-rest-6.1
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
        $BranchName,

        [Parameter()]
        [string[]]
        $Definitions,

        [Parameter()]
        [string[]]
        $BuildIds,

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
        If ($BuildIds)
        {
            $builds = Get-APBuildList @Splat -ApiVersion '5.1' -BuildIds $BuildIds
        }
        else
        {
            $builds = Foreach ($filter in $STATUS_FILTER)
            {
                Get-APBuildList @Splat -ApiVersion '5.1' -StatusFilter $filter -BranchName $BranchName -Definitions $Definitions
            }
        }
        $approvalObject = Foreach ($build in $builds)
        {
            $timeline = Get-APBuildTimeline @Splat -ApiVersion '5.1' -BuildId $build.id -TimelineId $build.orchestrationPlan.planId
            $records = $timeline.records | Where-Object { $RECORD_TYPES -contains $PSitem.Type}
            $approvals = $records.Where( {$PSitem.type -eq 'Checkpoint.Approval' -and $PSitem.state -eq 'inprogress'} )
            foreach ($approval in $approvals)
            {
                $checkpoint = $records.Where( {$Psitem.id -eq $approval.parentId} )
                $stage = $records.Where( {$Psitem.id -eq $checkpoint.parentId} )
                If ($ExpandApproval.IsPresent)
                {
                    $approvalLookup = Get-APPipelineApproval @Splat -ApiVersion '6.1-preview' -ApprovalId $approval.Id
                    [pscustomObject]@{
                        pipelineDefinitionName = $build.definition.Name
                        pipelineDefinitionId   = $build.definition.id
                        pipelineRunId          = $build.id
                        pipelineUrl            = $build._links.web.href
                        sourceBranch           = $build.sourceBranch
                        stageName              = $stage.name
                        stageIdentifier        = $stage.identifier
                        approvalId             = $approval.id
                        approval               = $approvalLookup
                    }
                }
                else
                {
                    [pscustomObject]@{
                        pipelineDefinitionName = $build.definition.Name
                        pipelineDefinitionId   = $build.definition.id
                        pipelineRunId          = $build.id
                        pipelineUrl            = $build._links.web.href
                        sourceBranch           = $build.sourceBranch
                        stageName              = $stage.name
                        stageIdentifier        = $stage.identifier
                        approvalId             = $approval.id
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