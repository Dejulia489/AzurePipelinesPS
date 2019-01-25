function Get-APApprovalList
{
    <#
    .SYNOPSIS

    Returns a list of Azure Pipeline approvals.

    .DESCRIPTION

    Returns a list of Azure Pipeline approvals based on a filter query.

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

    .PARAMETER Session

    Azure DevOps PS session, created by New-APSession.
    
    .PARAMETER AssignedToFilter

    Approvals assigned to this user.

    .PARAMETER StatusFilter

    Approvals with this status. Default is 'pending'.

    .PARAMETER ReleaseIdsFilter

    Approvals for release id(s) mentioned in the filter. Multiple releases can be mentioned by separating them with ',' e.g. releaseIdsFilter=1,2,3,4.

    .PARAMETER TypeFilter

    Approval with this type.

    .PARAMETER Top

    Number of approvals to get. Default is 50.

    .PARAMETER ContinuationToken

    Gets the approvals after the continuation token provided.

    .PARAMETER QueryOrder

    Gets the results in the defined order of created approvals. Default is 'descending'.

    .PARAMETER IncludeMyGroupApprovals
    
    'true' to include my group approvals. Default is 'false'.

    .INPUTS
    
    None, does not support pipeline.

    .OUTPUTS

    PSObject, Azure Pipelines approval(s)

    .EXAMPLE

    Returns an AP approval list for the current user in the 'myFirstProject'.

    Get-APApprovalList -Instance 'https://dev.azure.com' -Collection 'myCollection' -Project 'myFirstProject' -ApiVersion 5.0-preview

    .LINK

    https://docs.microsoft.com/en-us/rest/api/azure/devops/release/approvals/list?view=azure-devops-rest-5.0
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

        [Parameter(Mandatory,
            ParameterSetName = 'BySession')]
        [object]
        $Session,

        [Parameter()]
        [string]
        $AssignedToFilter,

        [Parameter()]
        [ValidateSet('approved','canceled','pending','reassigned','rejected','skipped','undefined')]
        [string[]]
        $StatusFilter,

        [Parameter()]
        [string[]]
        $ReleaseIdsFilter,

        [Parameter()]
        [ValidateSet('all', 'postDeploy', 'preDeploy', 'undefined')]
        [string]
        $TypeFilter,

        [Parameter()]
        [int]
        $Top,   
        
        [Parameter()]
        [int]
        $ContinuationToken,

        [Parameter()]
        [ValidateSet('ascending', 'descending')]
        [string]
        $QueryOrder,

        [Parameter()]
        [bool]
        $IncludeMyGroupApprovals
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
        $apiEndpoint = Get-APApiEndpoint -ApiType 'release-approvals'
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
            Method              = 'GET'
            Uri                 = $uri
            Credential          = $Credential
            PersonalAccessToken = $PersonalAccessToken
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