function Wait-APTimelineRecord {
    <#
    .SYNOPSIS

    Waits for an Azure Pipelines pipeline run timeline record to enter a specific state.

    .DESCRIPTION

    Waits for an Azure Pipelines pipeline run timeline record to enter a specific state.
    The id can be retrieved by using Get-APRunList.

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

    The ID of the pipeline run.

    .PARAMETER Timeout
	
    Timeout threshold in seconds.

    .PARAMETER PollingInterval
	
    The number of seconds to wait before checking the status of the build, defaults to 1.

    .INPUTS
    
    None, does not support pipeline.

    .OUTPUTS

    PSObject, Azure Pipelines build(s)

    .EXAMPLE

    Waits for the timeline record named 'QA Deploy' with a record type of 'Stage' enter the record state of 'pending'.

    $splat = @{
        Session     = $session
        RecordName  = 'QA Deploy'
        RecordType  = 'Stage'
        RecordState = 'pending'
        RunId       = 1000
        Verbose     = $true
    }
    Wait-APTimelineRecord @splat
    .LINK

    https://learn.microsoft.com/en-us/rest/api/azure/devops/pipelines/runs/get?view=azure-devops-rest-6.0
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
        [int]
        $RunId,

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
        $_timeout = (Get-Date).AddSeconds($TimeOut)
        $splat = @{
            Collection  = $Collection
            Instance    = $Instance
            Project     = $Project
            ApiVersion  = $ApiVersion
            ErrorAction = 'Stop'
        }
        If ($PersonalAccessToken) {
            $splat.PersonalAccessToken = $PersonalAccessToken
        }
        If ($Credential) {
            $splat.Credential = $Credential
        }
        If ($Proxy) {
            $splat.Proxy = $Proxy
        }
        If ($ProxyCredential) {
            $splat.ProxyCredential = $ProxyCredential
        }
        $runData = Get-APBuild @splat -BuildId $RunId -ErrorAction 'Stop'
        Do {
            $timeline = Get-APBuildTimeline @Splat -BuildId $runData.Id -TimelineId $runData.orchestrationPlan.planId
            $record = $timeline.records.Where( { $PSitem.name -eq $RecordName -and $PSitem.type -eq $RecordType } )
            If ($record.state -ne $RecordState) {
                Write-Verbose ("[{0}] Current status is: [$($record.state)]. Sleeping for [$($PollingInterval)] seconds" -f (Get-Date -Format G))
                Start-Sleep -Seconds $PollingInterval
            }
            else {
                return $record
            }
        }
        Until ((Get-Date) -ge $_timeout)

        Write-Error "[$($MyInvocation.MyCommand.Name)]: Timed out after [$TimeOut] seconds. [$($runData._links.web.href)]"
    }
    
    end {
    }
}