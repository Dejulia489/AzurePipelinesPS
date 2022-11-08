function Update-APTeamSettings
{
    <#
    .SYNOPSIS

    Updates an Azure Pipeline team settings based on the team id.

    .DESCRIPTION

    Updates an Azure Pipeline team settings based on the team id.
    The id can be returned using Get-APTeamList.

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

    .PARAMETER TeamId

    The name or guid id of a team.

    .PARAMETER BacklogIteration

    The id of the iteration.
    
    .PARAMETER BacklogVisibilities

    The id of the iteration.

    .PARAMETER BugsBehavior

    The team's bug behavior.

    .PARAMETER DefaultIteration

    The team's default iteration.

    .PARAMETER DefaultIterationMacro

    The team's default iteration macro.

    .PARAMETER WorkingDays

    The team's working days.

    .INPUTS
    
    None, does not support the pipeline.

    .OUTPUTS

    PSObject, Azure Pipelines team(s)

    .EXAMPLE

    Updates the working days for the team named 'myTeam'.

    $workingDays = 'monday', 'tuesday'
    Update-APTeamSettings -Session $session -TeamId 'myTeam' -WorkingDays $workingDays

    .EXAMPLE

    Updates the backlog iteration for 'team1'.

    Update-APTeamSettings -Session $session -TeamId 'Team1' -BacklogIteration '000000-0000-0000-0000-0000000000' 

    .EXAMPLE

    Update the team's backlog visibilities.

    $visibilities = @{
        'Microsoft.EpicCategory' = $false
        'Microsoft.RequirementCategory' = $true
        'Microsoft.FeatureCategory' = $true
    }
    Update-APTeamSettings -Session $session -TeamId 'Team1' -BacklogVisibilities $visibilities

    .LINK

    https://docs.microsoft.com/en-us/rest/api/azure/devops/work/teamsettings/update?view=azure-devops-rest-6.0
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
        $TeamId,

        [Parameter()]
        [string]
        $BacklogIteration,

        [Parameter()]
        [object]
        $BacklogVisibilities,

        [Parameter()]
        [ValidateSet('asRequirements', 'asTasks', 'off')]
        [string]
        $BugsBehavior, 

        [Parameter()]
        [string]
        $DefaultIteration,

        [Parameter()]
        [string]
        $DefaultIterationMacro,

        [Parameter()]
        [ValidateSet('sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday')]
        [string[]]
        $WorkingDays
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
        If ($BacklogIteration)
        {
            $body.backlogIteration = $BacklogIteration
        }
        If ($BacklogVisibilities)
        {
            $body.backlogVisibilities = $BacklogVisibilities
        }
        If ($BugsBehavior)
        {
            $body.bugsBehavior = $BugsBehavior
        }
        If ($DefaultIteration)
        {
            $body.defaultIteration = $DefaultIteration
        }
        If ($DefaultIterationMacro)
        {
            $body.defaultIterationMacro = $DefaultIterationMacro
        }
        If ($WorkingDays)
        {
            $body.workingDays = $WorkingDays
        }
        $apiEndpoint = (Get-APApiEndpoint -ApiType 'work-teamsettings') -f $TeamId
        $queryParameters = Set-APQueryParameters -InputObject $PSBoundParameters
        $setAPUriSplat = @{
            Collection  = $Collection
            Instance    = $Instance
            Project     = $Project
            ApiVersion  = $ApiVersion
            ApiEndpoint = $apiEndpoint
            Query       = $queryParameters
        }
        [uri] $uri = Set-APUri @setAPUriSplat
        $invokeAPRestMethodSplat = @{
            Method              = 'PATCH'
            Uri                 = $uri
            Credential          = $Credential
            PersonalAccessToken = $PersonalAccessToken
            Body                = $body
            ContentType         = 'application/json'
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