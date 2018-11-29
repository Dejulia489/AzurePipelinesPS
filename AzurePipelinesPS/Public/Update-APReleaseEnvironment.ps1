function Update-APReleaseEnvironment
{
    <#
    .SYNOPSIS

    Update the status of a release environment.

    .DESCRIPTION

    Update the status of a release environment by release id and environment id
    The release id can be retrieved by using Get-APReleaseList.
    The environment id can be retrieved by using Get-APRelease and providing the release id.
    The environment id is nested in the release object that is returned.

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

    .PARAMETER ReleaseID
    
    Id of the release.

    .PARAMETER EnvironmentID
    
    Id of the release environment.

    .PARAMETER Comment
    
    Comment used for the release status change.
    
    .PARAMETER ScheduledDeploymentTime
    
    Scheduled deployment time.
    
    .PARAMETER Status
    
    Environment status.    

    .INPUTS
    

    .OUTPUTS

    PSObject, Release Environment

    .EXAMPLE

    C:\PS> Update-APReleaseEnvironment -Instance 'https://dev.azure.com' -Collection 'myCollection' -Project 'myFirstProject' -ReleaseId 3 -EnvironmentId 8099

    .LINK

    https://docs.microsoft.com/en-us/rest/api/vsts/release/releases/update%20release%20environment?view=vsts-rest-5.0
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
        
        [Parameter(Mandatory)]
        [int]
        $ReleaseId,

        [Parameter(Mandatory)]
        [int]
        $EnvironmentId,

        [Parameter()]
        [string]
        $Comment, 

        [Parameter()]
        [string]
        $ScheduledDeploymentTime,

        [Parameter(Mandatory)]
        [string]
        [ValidateSet('canceled', 'inProgress', 'notStarted', 'partiallySucceeded', 'queued', 'rejected', 'scheduled', 'succeeded', 'undefined')]
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
        $body = @{
            status = $Status
        }
        if ($Comment)
        {
            $body.comment = $Comment
        }
        If ($ScheduledDeploymentTime)
        {
            $body.scheduledDeploymentTime = $ScheduledDeploymentTime
        }
        $apiEndpoint = (Get-APApiEndpoint -ApiType 'release-environmentId') -f $ReleaseId, $EnvironmentId
        [uri] $uri = Set-APUri -Instance $Instance -Collection $Collection -Project $Project -ApiEndpoint $apiEndpoint -ApiVersion $ApiVersion
        $invokeAPRestMethodSplat = @{
            ContentType         = 'application/json'
            Method              = 'PATCH'
            Body                = $body
            Uri                 = $uri
            Credential          = $Credential
            PersonalAccessToken = $PersonalAccessToken
        }
        Invoke-APRestMethod @invokeAPRestMethodSplat
    }
    
    end
    {
    }
}