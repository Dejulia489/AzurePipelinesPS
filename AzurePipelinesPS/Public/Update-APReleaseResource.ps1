function Update-APReleaseResource
{
    <#
    .SYNOPSIS

    Modifies an Azure Pipeline release resources.

    .DESCRIPTION

    Modifies an Azure Pipeline release resources by release id. 
    The id can be retrieved by using Get-APreleaseList.

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

    .PARAMETER ReleaseId

    The id of the release to ne modified.

    .PARAMETER Comment

    Sets comment for release.

    .PARAMETER KeepForever  

    Set 'true' to exclude the release from retention policies.

    .PARAMETER ManualEnvironments

    Sets list of manual environments.

    .PARAMETER Status

    Sets status of the release.

    .INPUTS
    

    .OUTPUTS

    None, Update-APReleaseResource returns Azure Pipelines release definition.

    .EXAMPLE

    C:\PS> Update-APReleaseResource -Instance 'https://dev.azure.com' -Collection 'myCollection' -Project 'myFirstProject' -ReleaseId 5 -Comment 'This is completed'

    .EXAMPLE

    C:\PS> Update-APReleaseResource -Instance 'https://dev.azure.com' -Collection 'myCollection' -Project 'myFirstProject' -ReleaseId 5 -Status 'abandoned'

    .LINK

    https://docs.microsoft.com/en-us/rest/api/azure/devops/release/releases/update%20release?view=azure-devops-rest-5.0
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
        $ReleaseId,

        [Parameter()]
        [string]
        $Comment,
        
        [Parameter()]
        [bool]
        $KeepForever,
        
        [Parameter()]
        [string[]]
        $ManualEnvironments,
        
        [Parameter()]
        [ValidateSet('abandoned','active','draft','undefined')]
        [string]
        $Status
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
                $ApiVersion = (Get-APApiVersion -Version $currentSession.Version)
                $PersonalAccessToken = $currentSession.PersonalAccessToken
            }
        }
    }
    
    process
    {
        $body = @{}
        If($PSBoundParameters.Keys -contains 'Comment')
        {
            $body.comment = $Comment
        }
        If($PSBoundParameters.Keys -contains 'KeepForever')        
        {
            $body.KeepForever = $KeepForever
        }
        If($PSBoundParameters.Keys -contains 'ManualEnvironments')        
        {
            $body.ManualEnvironments = $ManualEnvironments
        }
        If($PSBoundParameters.Keys -contains 'Status')        
        {
            $body.Status = $Status
        }
        $apiEndpoint = (Get-APApiEndpoint -ApiType 'release-releaseId') -f $ReleaseId
        $setAPUriSplat = @{
            Collection  = $Collection
            Instance    = $Instance
            Project     = $Project
            ApiVersion  = $ApiVersion
            ApiEndpoint = $apiEndpoint
        }
        [uri] $uri = Set-APUri @setAPUriSplat
        $invokeAPRestMethodSplat = @{
            ContentType = 'application/json'
            Body        = $body
            Method      = 'PATCH'
            Uri         = $uri
            Credential  = $Credential
            PersonalAccessToken = $PersonalAccessToken
        }
        $results = Invoke-APRestMethod @invokeAPRestMethodSplat 
        If ($results.count -eq 0)
        {
            Return
        }
        ElseIf ($results.value)
        {
            Return $results.value
        }
        Else
        {
            Return $results
        }
    }
    
    end
    {
    }
}