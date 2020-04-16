function New-APEnvironmentApproval
{
    <#
    .SYNOPSIS

    Creates an Azure Pipeline environment approval.

    .DESCRIPTION

    Creates an Azure Pipeline environment approval based on environment id.
    The id can be retrieved with Get-APEnvironment.

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

    .PARAMETER PrincipalName

    The principal name of the user or group to add to the approval.

    .PARAMETER EnvironmentId

    The name or id of the environment to create the approval for.

    .PARAMETER TimeoutDays

    The number of days before the approval times out.

    .PARAMETER Instructions

    The instructions provided to the approver upon approval request.

    .PARAMETER ExecutionOrder

    The order in which the approvals should be enforced, any or specific.
    
    .PARAMETER RequiredNumberOfApprovers

    The number of approvers required, specify 0 to require all approvers, defaults to 1.

    .PARAMETER RequesterCannotBeApprover

    Bool, the requester cannot be approver.

    .INPUTS
    
    None, does not support pipeline.

    .OUTPUTS

    PSObject, Azure Pipelines environment.

    .EXAMPLE

    Creates an Azure DevOps environment approval for 'My DisplayName'.

    New-APEnvironmentApproval -Session $session -DisplayName 'My DisplayName' -EnvironmentId 2 -TimeoutDays 3 -ExecutionOrder Any -RequiredNumberOfApprovers 0 -RequesterCannotBeApprover $true

    .LINK

    Undocumented at the time this was created.
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
        [string[]]
        $PrincipalName,

        [Parameter(Mandatory)]
        [string]
        $EnvironmentId,

        [Parameter(Mandatory)]
        [ValidateRange(1, 30)]
        [string]
        $TimeoutDays, 

        [Parameter()]
        [string]
        $Instructions,

        [Parameter(Mandatory)]
        [ValidateSet('Any', 'Specifc')]
        [string]
        $ExecutionOrder,

        [Parameter()]
        [int]
        $RequiredNumberOfApprovers = 1,

        [Parameter()]
        [bool]
        $RequesterCannotBeApprover
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
        Enum executionOrder
        {
            Any = 0
            Specifc = 1
        }
        $apSplat = @{
            Instance    = $Instance
            Collection  = $Collection
            ApiVersion  = $ApiVersion
            ErrorAction = 'Stop'
        }
        If ($PersonalAccessToken)
        {
            $apSplat.PersonalAccessToken = $PersonalAccessToken
        }
        If ($Credential)
        {
            $apSplat.Credential = $Credential
        }
        If ($Proxy)
        {
            $apSplat.Proxy = $Proxy
        }
        If ($ProxyCredential)
        {
            $apSplat.ProxyCredential = $ProxyCredential
        }
        $apEnvironment = Get-APEnvironment @apSplat -EnvironmentId $EnvironmentId -Project $Project
        $userList = Get-APUserList @apSplat | Where-Object { $PrincipalName -Contains $PSitem.principalName }
        [array] $approvers = Foreach ($user in $userList)
        {
            @{
                displayName = $user.displayName 
                id          = (Get-APStorageKey @apSplat -SubjectDescriptor $user.descriptor)
                descriptor  = $user.descriptor
                imageUrl    = $user.imageUrl
                uniqueName  = $user.principalName
            }
        }
        $groupList = Get-APGroupList @apSplat | Where-Object { $PrincipalName -Contains $PSitem.principalName }
        $approvers += Foreach ($group in $groupList)
        {
            @{
                displayName = $group.displayName 
                id          = (Get-APStorageKey @apSplat -SubjectDescriptor $group.descriptor)
                descriptor  = $group.descriptor
                imageUrl    = $group.imageUrl
                uniqueName  = $group.principalName
            }
        }
        $body = @{
            settings = @{
                approvers                 = $approvers 
                executionOrder            = [int] [executionOrder].$ExecutionOrder
                minRequiredApprovers      = $RequiredNumberOfApprovers
                instructions              = $Instructions
                requesterCannotBeApprover = $RequesterCannotBeApprover
                blockedApprovers          = @()
            }
            type     = @{
                name = 'Approval'
                id   = '8C6F20A7-A545-4486-9777-F762FAFE0D4D'
            }
            resource = @{
                type = 'environment'
                id   = $apEnvironment.Id
                name = $apEnvironment.Name
            }
            timeout  = (New-TimeSpan -Days $TimeoutDays).TotalMinutes
        }
        $apiEndpoint = Get-APApiEndpoint -ApiType 'pipelines-configurations'
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
            Body                = $body
            ContentType         = 'application/json'
            Proxy               = $Proxy
            ProxyCredential     = $ProxyCredential
        }
        $results = Invoke-APRestMethod @invokeAPRestMethodSplat 
        If ($results.value)
        {
            $results.value
        }
        else
        {
            $results
        }
    }

    end
    {
 
    }
}