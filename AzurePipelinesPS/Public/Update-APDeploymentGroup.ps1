function Update-APDeploymentGroup
{
    <#
    .SYNOPSIS

    Modifies an Azure Pipeline deployment group.

    .DESCRIPTION

    Modifies an Azure Pipeline deployment group.

    .PARAMETER Instance
    
    The Team Services account or TFS server.
    
    .PARAMETER Collection
    
    The value for collection should be DefaultCollection for both Team Services and TFS.

    .PARAMETER Project
    
    Project ID or project name.

    .PARAMETER DeploymentGroupId
    
    ID of the deployment.

    .PARAMETER Description
    
    Description of the deployment group.
 
    .PARAMETER Name
    
    Name of the deployment group.    
 
    .PARAMETER ApiVersion
    
    Version of the api to use.

    .PARAMETER Credential

    Specifies a user account that has permission to send the request.

    .INPUTS
    

    .OUTPUTS

    PSobject, An Azure Pipelines deployment group.

    .EXAMPLE

    C:\PS> Update-APDeploymentGroup -Instance 'https://myproject.visualstudio.com' -Collection 'DefaultCollection' -Project 'myFirstProject' -DeploymentGroupID 6

    .LINK

    https://docs.microsoft.com/en-us/rest/api/vsts/distributedtask/deploymentgroups/delete?view=vsts-rest-5.0#
    #>
    [CmdletBinding(DefaultParameterSetName = 'ByPersonalAccessToken')]
    Param
    (
        [Parameter(ParameterSetName = 'ByPersonalAccessToken')]
        [Parameter(ParameterSetName = 'ByCredential')]
        [uri]
        $Instance,
    
        [Parameter(ParameterSetName = 'ByPersonalAccessToken')]
        [Parameter(ParameterSetName = 'ByCredential')]
        [string]
        $Collection,
    
        [Parameter(ParameterSetName = 'ByPersonalAccessToken')]
        [Parameter(ParameterSetName = 'ByCredential')]
        [string]
        $Project,
    
        [Parameter(ParameterSetName = 'ByPersonalAccessToken')]
        [Parameter(ParameterSetName = 'ByCredential')]
        [string]
        $ApiVersion,
    
        [Parameter(ParameterSetName = 'ByPersonalAccessToken')]
        [Security.SecureString]
        $PersonalAccessToken,
    
        [Parameter(ParameterSetName = 'ByCredential')]
        [pscredential]
        $Credential,
    
        [Parameter(ParameterSetName = 'BySession')]
        [object]
        $Session,

        [Parameter(Mandatory)]
        [int]
        $DeploymentGroupId,

        [Parameter()]
        [string]
        $Name,

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
                $Project = $currentSession.Project
                $ApiVersion = (Get-APApiVersion -Version $currentSession.Version)
                $PersonalAccessToken = $currentSession.PersonalAccessToken
            }
        }
    }
    
    process
    {
        $body = @{
            Name        = $Name
            Description = $Description
        }
        $apiEndpoint = (Get-APApiEndpoint -ApiType 'distributedtask-deploymentGroupId') -f $DeploymentGroupID
        $setAPUriSplat = @{
            Collection  = $Collection
            Instance    = $Instance
            Project     = $Project
            ApiVersion  = $ApiVersion
            ApiEndpoint = $apiEndpoint
        }
        [uri] $uri = Set-APUri @setAPUriSplat
        $invokeAPRestMethodSplat = @{
            Method              = 'PATCH'
            Uri                 = $uri
            Credential          = $Credential
            PersonalAccessToken = $PersonalAccessToken
            Body                = $body
            ContentType         = 'application/json'
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