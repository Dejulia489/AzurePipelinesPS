function Copy-APTeam
{
    <#
    .SYNOPSIS

    Copies an existing Azure Pipelines team. 
    **Cross organization membership copy is not supported at this time**

    .DESCRIPTION

    Copies an existing Azure Pipelines team by name or id.
    **Cross organization membership copy is not supported at this time**
    Return a list of teams with Get-APTeamList.

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

    .PARAMETER TargetInstance

    The Team Services account or TFS server.

    .PARAMETER TargetCollection

    For Azure DevOps the value for collection should be the name of your orginization. 
    For both Team Services and TFS The value should be DefaultCollection unless another collection has been created.

    .PARAMETER TargetProject

    Project ID or project name.

    .PARAMETER TargetApiVersion

    Version of the api to use.

    .PARAMETER TargetPersonalAccessToken

    Personal access token used to authenticate that has been converted to a secure string. 
    It is recomended to uses an Azure Pipelines PS session to pass the personal access token parameter among funcitons, See New-APSession.
    https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=vsts

    .PARAMETER TargetCredential

    Specifies a user account that has permission to send the request.

    .PARAMETER TargetProxy

    Use a proxy server for the request, rather than connecting directly to the Internet resource. Enter the URI of a network proxy server.

    .PARAMETER TargetProxyCredential

    Specifie a user account that has permission to use the proxy server that is specified by the -Proxy parameter. The default is the current user.

    .PARAMETER TargetSession

    Azure DevOps PS session, created by New-APSession.

    .PARAMETER TeamId

    The id of the team to copy.

    .PARAMETER Name

    The name of the team.

    .PARAMETER NewName

    The name of the new team.

    .PARAMETER UpdateExisting

    If the team exists in the target update it. 
    Used for syncing teams across projects.

    .PARAMETER ExcludeTeamSettings

    Exclude the team's settings.

    .PARAMETER ExcludeTeamFields

    Exclude the team's fields.

    .PARAMETER ExcludeTeamMembers

    Exclude the team's members.

    .INPUTS

    None, does not support pipeline.

    .OUTPUTS

    PSObject, Azure Pipelines team.

    .EXAMPLE

    Copies a team with the team's backlog and iteration settings.

    Copy-APTeam -Instance 'https://dev.azure.com' -Collection 'myCollection' -Project 'myFirstProject' -Name 'myTeam'

    .EXAMPLE

    Copies a team without it's backlog and iteration settings.

    Copy-APTeam -Session $session -TeamId 'myTeam -ExcludeTeamSettings

    .EXAMPLE

    Copies 'myTeam' with it's settings and names the new team 'Team 1'.

    Copy-APTeam -Session $session -TeamId 'myTeam -NewName 'Team 1'

    .LINK

    Get AP Team
    https://docs.microsoft.com/en-us/rest/api/azure/devops/core/teams/get?view=azure-devops-rest-5.1

    Get AP Team Settings
    https://docs.microsoft.com/en-us/rest/api/azure/devops/work/teamsettings/get?view=azure-devops-rest-6.0
    
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
        [uri]
        $TargetInstance,

        [Parameter()]
        [string]
        $TargetCollection,

        [Parameter()]
        [string]
        $TargetProject,

        [Parameter()]
        [string]
        $TargetApiVersion,

        [Parameter(ParameterSetName = 'ByPersonalAccessToken')]
        [Security.SecureString]
        $TargetPersonalAccessToken,

        [Parameter(ParameterSetName = 'ByCredential')]
        [pscredential]
        $TargetCredential,

        [Parameter()]
        [string]
        $TargetProxy,

        [Parameter()]
        [pscredential]
        $TargetProxyCredential,

        [Parameter()]
        [object]
        $TargetSession,

        [Parameter()]
        [string]
        $TeamId, 

        [Parameter()]
        [string]
        $NewName,

        [Parameter()]
        [switch]
        $UpdateExisting,

        [Parameter()]
        [switch]
        $ExcludeTeamSettings,

        [Parameter()]
        [switch]
        $ExcludeTeamFields,

        [Parameter()]
        [switch]
        $ExcludeTeamMembers
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
            $currentTargetSession = $TargetSession | Get-APSession
            If ($currentTargetSession)
            {
                $TargetInstance = $currentTargetSession.Instance
                $TargetCollection = $currentTargetSession.Collection
                $TargetProject = $currentTargetSession.Project
                $TargetPersonalAccessToken = $currentTargetSession.PersonalAccessToken
                $TargetCredential = $currentTargetSession.Credential
                $TargetProxy = $currentTargetSession.Proxy
                $TargetProxyCredential = $currentTargetSession.ProxyCredential
                If ($currentTargetSession.Version)
                {
                    $TargetApiVersion = (Get-APApiVersion -Version $currentTargetSession.Version)
                }
                else
                {
                    $TargetApiVersion = $currentTargetSession.ApiVersion
                }
            }
        }
    }

    process
    {
        $sourceSplat = @{
            Instance        = $Instance
            Collection      = $Collection 
            Project         = $Project
            Proxy           = $Proxy
            ProxyCredential = $ProxyCredential
            ErrorAction     = 'Stop'
        } 
        If ($PersonalAccessToken)
        {
            $sourceSplat.PersonalAccessToken = $PersonalAccessToken
        }
        If ($Credential)
        {
            $sourceSplat.Credential = $Credential
        }
        If (-not($TargetInstance))
        {
            $TargetInstance = $Instance
        }
        If (-not($TargetCollection))
        {
            $TargetCollection = $Collection
        }
        If (-not($TargetProject))
        {
            $TargetProject = $Project
        }
        If (-not($TargetApiVersion))
        {
            $TargetApiVersion = $ApiVersion
        }
        If (-not($TargetPersonalAccessToken))
        {
            $TargetPersonalAccessToken = $PersonalAccessToken
        }
        If (-not($TargetCredential))
        {
            $TargetCredential = $Credential
        }
        If (-not($TargetProxy))
        {
            $TargetProxy = $Proxy
        }
        If (-not($TargetProxyCredential))
        {
            $TargetProxyCredential = $ProxyCredential
        }
        $targetSplat = @{
            Instance        = $TargetInstance
            Collection      = $TargetCollection 
            Proxy           = $TargetProxy
            ProxyCredential = $TargetProxyCredential
            ErrorAction     = 'Stop'
        }
        If ($PersonalAccessToken)
        {
            $targetSplat.PersonalAccessToken = $TargetPersonalAccessToken
        }
        If ($Credential)
        {
            $targetSplat.Credential = $TargetCredential
        }
       
        If ($TeamId)
        {
            $teams = Get-APTeam @sourceSplat -TeamId $TeamId -ApiVersion $ApiVersion
            If (-not($NewName))
            {
                $NewName = $TeamId
            }
        }
        else
        {
            $teams = Get-APTeamList @sourceSplat -ApiVersion $ApiVersion | Where-Object { $PSItem.name -eq $Name }
            If (-not($teams))
            {
                Write-Error "[$($MyInvocation.MyCommand.Name)]: Unable to locate a team named [$Name] in [$Collection]\[$Project] " -ErrorAction 'Stop'
            }
            If (-not($NewName))
            {
                $NewName = $Name
            }
        }
        Foreach ($team in $teams)
        {
            If ($UpdateExisting.IsPresent)
            {
                $team = Get-APTeam @sourceSplat -TeamId $team.Id -ApiVersion $ApiVersion
                try
                {
                    $newTeam = Get-APTeam @targetSplat -Project $TargetProject -TeamId $NewName -ApiVersion $ApiVersion
                }
                catch
                {
                    $newTeam = New-APTeam @targetSplat -Project $TargetProject -ApiVersion $TargetApiVersion -Name $NewName
                }
            }
            else
            {
                # Append copy to new name
                Do
                {
                    try
                    {
                        $null = Get-APTeam @targetSplat -Project $TargetProject -TeamId $NewName -ApiVersion $ApiVersion
                        $foundTeam = $true
                        $NewName = $NewName + ' Copy'
                    }
                    catch
                    {
                        $foundTeam = $false
                    }
                } While ($foundTeam)

                $team = Get-APTeam @sourceSplat -TeamId $team.Id -ApiVersion $ApiVersion
                $newTeam = New-APTeam @targetSplat -Project $TargetProject -ApiVersion $TargetApiVersion -Name $NewName
            }
            $results = @{
                team = $newTeam
            }
            If (-not($ExcludeTeamSettings.IsPresent))
            {
                $teamSettings = Get-APTeamSettings @sourceSplat -TeamId $team.Id -ApiVersion $ApiVersion
                If ($teamSettings.BacklogIteration.Path)
                {
                    $targetBacklogIteration = Get-APNode @targetSplat -Project $targetProject -Path $teamSettings.BacklogIteration.Path -ApiVersion 6.0 -StructureGroup 'Iterations'
                }
                If ($teamSettings.DefaultIteration.Path)
                {
                    $targetDefaultIteration = Get-APNode @targetSplat -Project $targetProject -Path $teamSettings.DefaultIteration.Path -ApiVersion 6.0 -StructureGroup 'Iterations'
                }
                If ($teamSettings.DefaultIterationMacro)
                {
                    $newTeamSettings = Update-APTeamSettings @targetSplat -Project $TargetProject -ApiVersion $TargetApiVersion -TeamId $newTeam.Id -BacklogIteration $targetBacklogIteration.identifier -DefaultIterationMacro $teamSettings.DefaultIterationMacro -BugsBehavior $teamSettings.BugsBehavior -BacklogVisibilities $teamSettings.BacklogVisibilities -WorkingDays $teamSettings.WorkingDays
                }
                else
                {
                    $newTeamSettings = Update-APTeamSettings @targetSplat -Project $TargetProject -ApiVersion $TargetApiVersion -TeamId $newTeam.Id -BacklogIteration $targetBacklogIteration.identifier -DefaultIteration $targetDefaultIteration.identifier -BugsBehavior $teamSettings.BugsBehavior -BacklogVisibilities $teamSettings.BacklogVisibilities -WorkingDays $teamSettings.WorkingDays
                }
                $results.settings = $newTeamSettings
            }
            If (-not($ExcludeTeamFields.IsPresent))
            {
                $teamFieldValues = Get-APTeamFieldValues @sourceSplat -TeamId $team.Id -ApiVersion $ApiVersion
                If ($teamFieldValues.DefaultValue)
                {
                    $defaultValueSplit = $teamFieldValues.DefaultValue.split('\')
                    $newTeamFieldDefaultValue = "{0}\{1}" -f $defaultValueSplit[0].Replace("$Project", "$TargetProject"), ($defaultValueSplit[1..$($defaultValueSplit.count)] -join '\')
                    $results.defaultValue = $newTeamFieldDefaultValue
                }
                If ($teamFieldValues.values)
                {
                    [array] $newTeamFieldValues = Foreach ($value in $teamFieldValues.values)
                    {
                        $split = $value.value.split('\')
                        @{
                            value           = ("{0}\{1}" -f $split[0].Replace("$Project", "$TargetProject"), ($split[1..$($split.count)] -join '\'))
                            includeChildren = $value.includeChildren
                        }
                    }
                    $newTeamFields = Update-APTeamFieldValues @targetSplat -Project $TargetProject -ApiVersion $TargetApiVersion -TeamId $newTeam.Id -DefaultValue $newTeamFieldDefaultValue -Values $newTeamFieldValues
                    $results.values = $newTeamFields
                }
            }
            If (-not($ExcludeTeamMembers.IsPresent))
            {
                # Locked to a working 5.1 version
                $newTeamMembers = Get-APTeamMembers @sourceSplat -TeamId $team.Id -ApiVersion '7.1-preview.2' -top 1000
                $membersAdded = Foreach ($member in $newTeamMembers)
                {
                    # Locked to a preview version
                    Add-APGroupMembership @targetSplat -ContainerDescriptor $newTeam.identity.subjectDescriptor -SubjectDescriptor $member.descriptor -ApiVersion '5.1-preview.1'
                }
                If ($membersAdded)
                {
                    $results.membersAdded = $true
                }
            }
            Write-Output $results
        }
    }

    end
    {
    }
}