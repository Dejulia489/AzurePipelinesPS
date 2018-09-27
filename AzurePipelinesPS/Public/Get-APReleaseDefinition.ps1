function Get-APReleaseDefinition
{
    <#
    .SYNOPSIS

    Returns Azure Pipeline release definition(s).

    .DESCRIPTION

    Returns Azure Pipeline release definitions(s) based on a filter query, if one is not provided the default will return the top 50 releases for the project provided.

    .PARAMETER Instance
    
    The Team Services account or TFS server.
    
    .PARAMETER Collection
    
    The value for collection should be DefaultCollection for both Team Services and TFS.

    .PARAMETER Project
    
    Project ID or project name.
    
    .PARAMETER DefinitionId
    
    Releases with names starting with searchText.

    .PARAMETER PropertyFilters
    
    The property that should be expanded in the list of releases.

    .PARAMETER ApiVersion
    
    Version of the api to use.

    .PARAMETER Credential

    Specifies a user account that has permission to send the request.

    .INPUTS
    

    .OUTPUTS

    PSObject, Azure Pipelines release definition(s).

    .EXAMPLE

    C:\PS> Get-APReleaseDefinition -Instance 'https://myproject.visualstudio.com' -Collection 'DefaultCollection' -Project 'myFirstProject' -DefinitionId 5

    .LINK

    https://docs.microsoft.com/en-us/rest/api/vsts/release/releases/list?view=vsts-rest-5.0
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

        [Parameter(Mandatory)]
        [int]
        $DefinitionId,

        [Parameter(ParameterSetName = 'ByQuery')]
        [string[]]
        $PropertyFilters,

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
            'DefinitionId'
        )
        $apiEndpoint = (Get-APApiEndpoint -ApiType 'release-definitionId') -f $DefinitionId
        $setAPUriSplat = @{
            Collection  = $Collection
            Instance    = $Instance
            Project     = $Project
            ApiVersion  = $ApiVersion
            ApiEndpoint = $apiEndpoint
        }
        If ($PSCmdlet.ParameterSetName -eq 'ByQuery')
        {
            $queryParams = Foreach ($key in $PSBoundParameters.Keys)
            {
                If($nonQueryParams -contains $key)
                {
                    Continue
                }
                ElseIf($key -eq 'Top')
                {
                    "`$$key=$($PSBoundParameters.$key)"
                }
                Else
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
        Invoke-APRestMethod @invokeAPRestMethodSplat | Select-Object -ExpandProperty value
    }
    
    end
    {
    }
}