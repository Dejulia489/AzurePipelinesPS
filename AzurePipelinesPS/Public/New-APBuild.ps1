function New-APBuild
{
    <#
    .SYNOPSIS

    Creates an Azure Pipeline build.

    .DESCRIPTION

    Creates an Azure Pipeline build by build definition name.

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

    .PARAMETER Name

    The name of the build definition to queue.

    .PARAMETER IgnoreWarnings

    Undocumented.

    .PARAMETER CheckInTicket

    Undocumented.

    .PARAMETER SourceBuildId

    Undocumented.

    .PARAMETER SourceBranch

    The branch to get sources.

    .INPUTS
    
    None, does not support pipeline.

    .OUTPUTS

    PSObject, Azure Pipelines build.

    .EXAMPLE

    .LINK

    https://docs.microsoft.com/en-us/rest/api/azure/devops/build/builds/queue?view=azure-devops-rest-5.0
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
        [string]
        $Name,

        [Parameter()]
        [bool]
        $IgnoreWarnings,

        [Parameter()]
        [string]
        $CheckInTicket,

        [Parameter()]
        [int]
        $SourceBuildId,

        [Parameter()]
        [string]
        $SourceBranch
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
        $getAPBuildDefinitionListSplat = @{
            Collection = $Collection
            Instance = $Instance
            Project = $Project
            ApiVersion = $ApiVersion
            Name = $Name
        }
        If($Credential)
        {
            $getAPBuildDefinitionListSplat.Credential = $Credential
        }
        If($PersonalAccessToken)
        {
            $getAPBuildDefinitionListSplat.PersonalAccessToken = $PersonalAccessToken
        }
        $definition = Get-APBuildDefinitionList @getAPBuildDefinitionListSplat
        $body = @{
            definition = $definition
        }
        If($SourceBranch)
        {
            $body.SourceBranch = $SourceBranch
        }
        $apiEndpoint = Get-APApiEndpoint -ApiType 'build-builds'
        $setAPUriSplat = @{
            Collection  = $Collection
            Instance    = $Instance
            Project     = $Project
            ApiVersion  = $ApiVersion
            ApiEndpoint = $apiEndpoint
        }
        [uri] $uri = Set-APUri @setAPUriSplat
        $invokeAPRestMethodSplat = @{
            Method              = 'POST'
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