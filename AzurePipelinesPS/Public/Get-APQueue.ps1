Function Get-APQueue
{
    <#
    .SYNOPSIS

    Returns Azure Pipeline queue(s).

    .DESCRIPTION

    Returns Azure Pipeline queue(s) based on a filter query.

    .PARAMETER Instance
    
    The Team Services account or TFS server.
    
    .PARAMETER Collection
    
    The value for collection should be DefaultCollection for both Team Services and TFS.

    .PARAMETER Project
    
    Project ID or project name.

    .PARAMETER QueueName

    Filters queues whose names start with this prefix.

    .PARAMETER ActionFilter

    Filter Queues based on the permission mentioned.

    .PARAMETER ApiVersion
    
    Version of the api to use.

    .PARAMETER Credential

    Specifies a user account that has permission to send the request.

    .INPUTS
    

    .OUTPUTS

    PSObject, Azure Pipelines queue(s)

    .EXAMPLE

    C:\PS> Get-APQueue -Instance 'https://myproject.visualstudio.com' -Collection 'DefaultCollection' -Project 'myFirstProject'

    .LINK

    https://docs.microsoft.com/en-us/rest/api/vsts/build/builds/list?view=vsts-rest-5.0
    #>
    [CmdletBinding(DefaultParameterSetName = 'ByList')]
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

        [Parameter(ParameterSetName = 'ByQuery')]
        [string]
        $QueueName,

        [Parameter(ParameterSetName = 'ByQuery')]
        [ValidateSet('none','manage','use')]
        [string]
        $ActionFilter,

        [Parameter()]
        [string]
        $ApiVersion = (Get-APApiVersion), 

        [Parameter()]
        [pscredential]
        $Credential
    )
    Begin
    {
    }
    Process
    {
        $apiEndpoint = Get-APApiEndpoint -ApiType 'distributedtask-queues'
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