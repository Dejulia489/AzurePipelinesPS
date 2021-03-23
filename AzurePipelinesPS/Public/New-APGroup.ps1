function New-APGroup
{
    <#
    .SYNOPSIS

    Create a new Azure DevOps group or materialize an existing AAD group.

    .DESCRIPTION

    The body of the request must be a derived type of GraphGroupCreationContext:

    GraphGroupVstsCreationContext - Create a new Azure DevOps group that is not backed by an external provider.
    GraphGroupMailAddressCreationContext - Create a new group using the mail address as a reference to an existing group from an external AD or AAD backed provider.
    GraphGroupOriginIdCreationContext - Create a new group using the OriginID as a reference to a group from an external AD or AAD backed provider.

    Optionally, you can add the newly created group as a member of an existing Azure DevOps group and/or specify a custom storage key for the group.

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

    .PARAMETER PrincipalName

    The principal name of the group.

    .PARAMETER ScopeDescriptor

    A descriptor referencing the scope (collection, project) in which the group should be created. If omitted, will be created in the scope of the enclosing account or organization. Valid only for VSTS groups.

    .PARAMETER GroupDescriptors

    A comma separated list of descriptors referencing groups you want the graph group to join

    .PARAMETER StorageKey

    Optional: If provided, we will use this identifier for the storage key of the created group

    .PARAMETER OriginId

    The unique identifier from the system of origin. Typically a sid, object id or Guid. Linking and unlinking operations can cause this value to change for a user because the user is not backed by a different provider and has a different unique id in the new provider.

    .PARAMETER DisplayName

    The displayname of the group.

    .PARAMETER Description

    The description of the group.

    .INPUTS
    
    None, does not support pipeline.

    .OUTPUTS

    PSObject, Azure Pipelines variable group.

    .EXAMPLE

    Gets Azure AD group and creates the group in Azure DevOps.
    
    $adGroup = Get-AzureADGroup -SearchString 'ADO_IntegrationServices_PreDeploymentApproval'
    New-APGroup -Session 'mySession' -OriginId $adGroup.ObjectId -Verbose

    .LINK

    https://docs.microsoft.com/en-us/rest/api/azure/devops/graph/groups/create?view=azure-devops-rest-5.1
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
        
        [Parameter()]
        [string]
        $PrincipalName,

        [Parameter()]
        [string]
        $ScopeDescriptor,

        [Parameter()]
        [string[]]
        $GroupDescriptors,

        [Parameter()]
        [string]
        $StorageKey, 

        [Parameter()]
        [string]
        $OriginId, 

        [Parameter()]
        [string]
        $DisplayName,

        [Parameter()]
        [string]
        $Description
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
        $body = @{ }
        If ($PrincipalName)
        {
            $body.principalName = $PrincipalName
        }
        If ($StorageKey)
        {
            $body.StorageKey = $StorageKey
        }
        If ($OriginId)
        {
            $body.originId = $OriginId
        }
        If ($DisplayName)
        {
            $body.displayName = $DisplayName
        }
        If ($Description)
        {
            $body.description = $Description
        }
        $apiEndpoint = Get-APApiEndpoint -ApiType 'graph-groups'
        $queryParameters = Set-APQueryParameters -InputObject $PSBoundParameters
        $setAPUriSplat = @{
            Collection         = $Collection
            Instance           = $Instance
            ApiVersion         = $ApiVersion
            ApiEndpoint        = $apiEndpoint
            Query              = $queryParameters
            ApiSubDomainSwitch = 'vssps'
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