function Update-APReleaseEnvironment
{
    <#
    .SYNOPSIS

    Update the status of a release environment.

    .DESCRIPTION

    Update the status of a release environment.

    .PARAMETER Instance
    
    The Team Services account or TFS server.
    
    .PARAMETER Collection
    
    The value for collection should be DefaultCollection for both Team Services and TFS.

    .PARAMETER Project
    
    Project ID or project name.

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

    .PARAMETER ApiVersion
    
    Version of the api to use.

    .PARAMETER Credential

    Specifies a user account that has permission to send the request.

    .INPUTS
    

    .OUTPUTS

    PSObject, Release Environment

    .EXAMPLE

    C:\PS> Update-APReleaseEnvironment -Instance 'https://myproject.visualstudio.com' -Collection 'DefaultCollection' -Project 'myFirstProject' -ReleaseId 3 -EnvironmentId 8099

    .LINK

    https://docs.microsoft.com/en-us/rest/api/vsts/release/releases/update%20release%20environment?view=vsts-rest-5.0
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter()]
        [uri]
        $Instance = (Get-APModuleData).Instance,

        [Parameter()]
        [string]
        $Collection = (Get-APModuleData).Collection,

        [Parameter(Mandatory)]
        [string]
        $Project,

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
        $Status,

        [Parameter()]
        [string]
        $ApiVersion = (Get-APApiVersion), 

        [Parameter()]
        [pscredential]
        $Credential
    )

    
    begin
    {
    }
    
    process
    {
        $body = @{
            status = $Status
        }
        if($Comment)
        {
            $body.comment = $Comment
        }
        If($ScheduledDeploymentTime)
        {
            $body.scheduledDeploymentTime = $ScheduledDeploymentTime
        }
        $apiEndpoint = (Get-APApiEndpoint -ApiType 'release-environmentId') -f $ReleaseId, $EnvironmentId
        [uri] $uri = Set-APUri -Instance $Instance -Collection $Collection -Project $Project -ApiEndpoint $apiEndpoint -ApiVersion $ApiVersion
        $invokeAPRestMethodSplat = @{
            ContentType = 'application/json'
            Method      = 'PATCH'
            Body        = $body
            Uri         = $uri
            Credential  = $Credential
        }
        Invoke-APRestMethod @invokeAPRestMethodSplat
    }
    
    end
    {
    }
}