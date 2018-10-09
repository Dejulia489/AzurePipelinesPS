function Publish-APBuildDefinition
{
    <#
    .SYNOPSIS

    Creates an Azure Pipelines build definition.

    .DESCRIPTION

    Creates an Azure Pipelines build definition with the output of Format-APTemplate.

    .PARAMETER Instance

    The Team Services account or TFS server.

    .PARAMETER Collection

    The value for collection should be DefaultCollection for both Team Services and TFS.

    .PARAMETER Project

    Project ID or project name.

    .PARAMETER DefinitionToCloneId

    Undefinied, see link for documentation.

    .PARAMETER DefinitionToCloneRevision

    Undefinied, see link for documentation.

    .PARAMETER ValidateProcessOnly

    Undefinied, see link for documentation.

    .PARAMETER Template

    The template provided by the Format-APTemplate function.

    .PARAMETER ApiVersion

    Version of the api to use.

    .PARAMETER Credential

    Specifies a user account that has permission to send the request.

    .INPUTS
        
    PSObject, the template provided by the Format-APTemplate function.

    .OUTPUTS

    PSobject, Azure Pipelines build.

    .EXAMPLE

    C:\PS> Publish-APBuildDefinition -Instance 'https://myproject.visualstudio.com' -Collection 'DefaultCollection' -Project 'myFirstProject' -DefinitionObject $template

    .LINK

    https://docs.microsoft.com/en-us/rest/api/vsts/build/definitions/create?view=vsts-rest-5.0
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

        [Parameter()]
        [int]
        $DefinitionToCloneId,

        [Parameter()]
        [int]
        $DefinitionToCloneRevision,

        [Parameter()]
        [bool]
        $ValidateProcessOnly,

        [Parameter(ParameterSetName = 'ByTemplate')]
        [PSobject]
        $Template
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
        $body = $Template
        $apiEndpoint = Get-APApiEndpoint -ApiType 'build-definitions'
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
            ContentType = 'application/json'
            Body        = $body
            Method      = 'POST'
            Uri         = $uri
            Credential  = $Credential
            PersonalAccessToken = $PersonalAccessToken
        }
        $results = Invoke-APRestMethod @invokeAPRestMethodSplat 
        If ($results.count -eq 0)
        {
            Write-Error "[$($MyInvocation.MyCommand.Name)]: returned nothing." -ErrorAction Stop
        }
        ElseIf ($results.value)
        {
            return $results.value
        }
        Else
        {
            return $results
        }
    }
    
    end
    {
    }
}