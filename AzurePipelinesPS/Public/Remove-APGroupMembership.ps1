function Remove-APGroupMembership
{
    <#
    .SYNOPSIS

    Deletes an Azure Pipeline release.

    .DESCRIPTION

    Deletes an Azure Pipeline release by release id. 
    The id can be retrieved by using Get-APGroupMembershipList.

    .PARAMETER Instance
    
    The Team Services account or TFS server.
    
    .PARAMETER Collection
    
    For Azure DevOps the value for collection should be the name of your orginization. 
    For both Team Services and TFS The value should be DefaultCollection unless another collection has been created.

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

    .PARAMETER SubjectDescriptor

    A descriptor to the child subject in the relationship.

    .PARAMETER ContainerDescriptor

    A descriptor to the container in the relationship.

    .INPUTS
    
    None, does not support pipeline.

    .OUTPUTS

    None, Remove-APGroupMembership does not generate any output.

    .EXAMPLE

    The example below provides a gridview of all groups. Then the members of the groups selected. Then removes the members selected from that group.

    $group = Get-APGroupList -Session $session | Out-GridView -PassThru
    Foreach ($g in $group)
    {
        $memberList = Get-APGroupMembershipList -Session $session -SubjectDescriptor $g.descriptor -Direction down
        $members = Foreach ($m in $memberList.memberDescriptor)
        {
            Get-APGroup -Session $session -GroupDescriptor $m
        }
        $membersToRemove = $members | Out-GridView -PassThru
        Foreach ($m in $membersToRemove)
        {
            Remove-APGroupMembership -Session $session -SubjectDescriptor $m.descriptor -ContainerDescriptor $g.descriptor -Verbose
        }
    }

    .LINK

    https://docs.microsoft.com/en-us/rest/api/azure/devops/graph/memberships/remove%20membership?view=azure-devops-rest-5.0
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
        $SubjectDescriptor,

        [Parameter(Mandatory)]
        [string]
        $ContainerDescriptor
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
        $apiEndpoint = (Get-APApiEndpoint -ApiType 'graph-containerDescriptor') -f $SubjectDescriptor, $ContainerDescriptor
        $setAPUriSplat = @{
            Collection         = $Collection
            Instance           = $Instance
            ApiVersion         = $ApiVersion
            ApiEndpoint        = $apiEndpoint
            ApiSubDomainSwitch = 'vssps'
        }
        [uri] $uri = Set-APUri @setAPUriSplat
        $invokeAPRestMethodSplat = @{
            Method              = 'DELETE'
            Uri                 = $uri
            Credential          = $Credential
            PersonalAccessToken = $PersonalAccessToken
            Proxy               = $Proxy
            ProxyCredential     = $ProxyCredential
        }
        Invoke-APRestMethod @invokeAPRestMethodSplat 
    }
    
    end
    {
    }
}