Function New-APGroupMembershipReport
{
    <#
    .SYNOPSIS

    Returns all members for a group(s).

    .DESCRIPTION

    Returns all members for a group(s), based on a filter.

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

    .PARAMETER Filter

    A where object filter to filter all groups.
    $Filter  = { $PSitem.principalName -match '_Administrators' }

    .INPUTS

    None, does not support pipeline.

    .OUTPUTS

    PSObject, Group and it's members

    .EXAMPLE

    New-APGroupMembershipReport -Session 'mySession' -Filter { $_.principalname -like '*Project Administrators' } -Verbose

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
        [scriptblock]
        $Filter
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
        $splat = @{
            Collection = $Collection
            Instance   = $Instance
            ApiVersion = $ApiVersion
        }
        If ($Credential)
        {
            $splat.Credential = $Credential
        }
        If ($PersonalAccessToken)
        {
            $splat.PersonalAccessToken = $PersonalAccessToken
        }
        If ($Proxy)
        {
            $splat.Proxy = $Proxy
        }
        If ($ProxyCredential)
        {
            $splat.ProxyCredential = $ProxyCredential
        }
        $allGroups = Get-APGroupList @splat
        $allUsers = Get-APUserList @splat
        if ($Filter)
        {
            $groups = $allGroups | Where-Object -FilterScript $Filter | Sort-Object -Property 'principalName'
        }
        else
        {
            $groups = $allGroups
        }
        Foreach ($group in $groups)
        {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)]: Processing [$($group.principalName)]"
            $members = Get-APGroupMembershipList @splat -SubjectDescriptor $group.descriptor -Direction down
            $groupMembers = Foreach ($member in $members)
            {
                If ($member.memberDescriptor)
                {
                    Switch -Wildcard ($member.memberDescriptor)
                    {
                        'aad.*'
                        {
                            $memberName = $allUsers.Where( { $PSitem.descriptor -eq $member.memberDescriptor }).principalName
                            break
                        }
                        '*gp.*'
                        {
                            $memberName = $allGroups.Where( { $PSitem.descriptor -eq $member.memberDescriptor }).principalName
                            break
                        }
                        Default
                        {
                            Write-Warning "[$($MyInvocation.MyCommand.Name)]: [$($member.memberDescriptor)] did not match."
                        }
                    }
                    $memberName
                }
            }
            @{
                Group   = $group.principalName
                Members = $groupMembers
            }
        }
    }
    
    end
    {

    }
}