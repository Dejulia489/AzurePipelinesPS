function Get-APTarget
{
    <#
    .SYNOPSIS

    Returns Azure Pipeline deployment group target.

    .DESCRIPTION

    Returns Azure Pipeline deployment group target based on a filter query.

    .PARAMETER Instance
    
    The Team Services account or TFS server.
    
    .PARAMETER Collection
    
    The value for collection should be DefaultCollection for both Team Services and TFS.

    .PARAMETER Project
    
    Project ID or project name.

    .PARAMETER DeploymentGroupId

    ID of the deployment target to return.

    .PARAMETER TargetID

    ID of the deployment target to return.

    .PARAMETER Expand

    Include these additional details in the returned objects.    

    .PARAMETER ApiVersion
    
    Version of the api to use.

    .PARAMETER Credential

    Specifies a user account that has permission to send the request.

    .INPUTS
    

    .OUTPUTS

    PSObject, Azure Pipelines deployment group.

    .EXAMPLE

    C:\PS> Get-APTarget -Instance 'https://myproject.visualstudio.com' -Collection 'DefaultCollection' -Project 'myFirstProject' -DeploymentGroupID 6 -TargetId 25

    .LINK

    https://docs.microsoft.com/en-us/rest/api/vsts/distributedtask/targets/get?view=vsts-rest-5.0
    #>
    [CmdletBinding(DefaultParameterSetName = 'Default')]
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
        $DeploymentGroupID,

        [Parameter(Mandatory)]
        [int]
        $TargetId,

        [Parameter(ParameterSetName = 'ByQuery')]
        [ValidateSet('assignedRequest','capabilities','lastCompletedRequest','none')]
        [string]
        $Expand,

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

        $apiEndpoint = (Get-APApiEndpoint -ApiType 'distributedtask-targetId') -f $DeploymentGroupID, $TargetId
        $setAPUriSplat = @{
            Collection  = $Collection
            Instance    = $Instance
            Project     = $Project
            ApiVersion  = $ApiVersion
            ApiEndpoint = $apiEndpoint
        }
        If ($PSCmdlet.ParameterSetName -eq 'ByQuery')
        {
            $nonQueryParams = @(
                'Instance',
                'Collection',
                'Project',
                'ApiVersion',
                'Credential',
                'Verbose',
                'Debug',
                'ErrorAction',
                'WarningAction', 
                'InformationAction', 
                'ErrorVariable', 
                'WarningVariable', 
                'InformationVariable', 
                'OutVariable', 
                'OutBuffer'
            )
            $queryParams = Foreach ($key in $PSBoundParameters.Keys)
            {
                If ($nonQueryParams -contains $key)
                {
                    Continue
                }
                ElseIf ($key -eq 'Top')
                {
                    "`$$key=$($PSBoundParameters.$key)"
                }
                ElseIf ($PSBoundParameters.$key.count)
                {
                    "$key={0}" -f ($PSBoundParameters.$key -join ',')
                }
                else
                {
                    "$key=$($PSBoundParameters.$key)"                    
                }
            }
            $setAPUriSplat.Query = ($queryParams -join '&').ToLower()
        }
        [uri] $uri = Set-APUri @setAPUriSplat
        $invokeAPRestMethodSplat = @{
            Method     = 'GET'
            Uri        = $uri
            Credential = $Credential
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