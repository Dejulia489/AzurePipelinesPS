function Publish-APBuildDefinition
{
    <#
    .SYNOPSIS

    Creates an Azure Pipelines build definition.

    .DESCRIPTION

    Creates an Azure Pipelines build definition by a template.
    A template can be retrieved by Get-APBuildDefinition.

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

    .PARAMETER DefinitionToCloneId

    Undefinied, see link for documentation.

    .PARAMETER DefinitionToCloneRevision

    Undefinied, see link for documentation.

    .PARAMETER ValidateProcessOnly

    Undefinied, see link for documentation.

    .PARAMETER Template

    The template provided by Get-APBuildDefinition.

    .INPUTS
        
    PSObject, the template provided by Get-APBuildDefinition.

    .OUTPUTS

    PSobject, Azure Pipelines build.

    .EXAMPLE

    Creates AP build definition from the $template provided. $template is a JSON representation of the definition that can be found in the history of the release deinifiton during editing.

    Publish-APBuildDefinition -Instance 'https://dev.azure.com' -Collection 'myCollection' -Project 'myFirstProject' -DefinitionObject $template

    .LINK

    https://docs.microsoft.com/en-us/rest/api/vsts/build/definitions/create?view=vsts-rest-5.0
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
        [int]
        $DefinitionToCloneId,

        [Parameter()]
        [int]
        $DefinitionToCloneRevision,

        [Parameter()]
        [bool]
        $ValidateProcessOnly,

        [Parameter()]
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