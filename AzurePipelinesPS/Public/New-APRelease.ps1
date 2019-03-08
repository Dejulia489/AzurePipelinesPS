function New-APRelease
{
    <#
    .SYNOPSIS

    Creates an Azure Pipeline release.

    .DESCRIPTION

    Creates an Azure Pipeline release by definition id.
    The id can be retrieved by using Get-APReleaseList.

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

    .PARAMETER DefinitionId

    Sets definition Id to create a release.

    .PARAMETER BuildId

    Id of the build to use as the artifact source, defaults to the latest build id.
    The buildId parameter does not support releases with multiple artifacts.

    .PARAMETER Description

    Sets description to create a release.

    .PARAMETER Reason

    Sets reason to create a release.

    .PARAMETER ManualEnvironments

    Sets list of environments to manual as condition.

    .PARAMETER IsDraft

    Sets 'true' to create release in draft mode, 'false' otherwise, defaults to 'false'.

    .PARAMETER Variables
    
    Sets list of release variables to be overridden at deployment time.

    .INPUTS
    
    None, does not support pipeline.

    .OUTPUTS

    PSObject, Azure Pipelines variable group.

    .EXAMPLE

    .LINK

    https://docs.microsoft.com/en-us/rest/api/azure/devops/release/releases/create?view=azure-devops-rest-5.0
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
        $DefinitionId,

        [Parameter()]
        [int]
        $BuildId,

        [Parameter()]
        [string]
        $Description,

        [Parameter()]
        [ValidateSet('continuousIntegration', 'manual', 'none', 'pullRequest', 'schedule')]
        [string]
        $Reason,

        [Parameter()]
        [string[]]
        $ManualEnvironments,

        [Parameter()]
        [string]
        $IsDraft = $false,

        [Parameter()]
        [hashtable]
        $Variables
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
        $getAPReleaseDefinitionSplat = @{
            Collection   = $Collection
            Project      = $Project
            ApiVersion   = $ApiVersion
            Instance     = $Instance
            DefinitionId = $DefinitionId
        }
        If ($PersonalAccessToken)
        {
            $getAPReleaseDefinitionSplat.PersonalAccessToken = $PersonalAccessToken
        }
        If ($Credential)
        {
            $getAPReleaseDefinitionSplat.Credential = $Credential
        }
        $definition = Get-APReleaseDefinition @getAPReleaseDefinitionSplat
        $_artifacts = @()
        Foreach ($artifactSource in $Definition.artifacts)
        {
            $getAPBuildDefinitionSplat = @{
                Collection = $Collection
                Project    = $Project
                ApiVersion = $ApiVersion
                Instance   = $Instance
                Top        = 1
            }
            If ($BuildId)
            {
                $getAPBuildDefinitionSplat.BuildIds = $BuildId
            }
            else
            {
                $getAPBuildDefinitionSplat.Definitions = $artifactSource.definitionReference.definition.id            
            }
            If ($PersonalAccessToken)
            {
                $getAPBuildDefinitionSplat.PersonalAccessToken = $PersonalAccessToken
            }
            If ($Credential)
            {
                $getAPBuildDefinitionSplat.Credential = $Credential
            }
            $build = Get-APBuildList @getAPBuildDefinitionSplat
            $_artifacts += @{
                alias             = $artifactSource.alias
                instanceReference = @{
                    id   = $build.id
                    name = $build.buildNumber
                }
            }
        }
        $body = @{
            DefinitionId       = $DefinitionId
            Description        = $Description
            Reason             = $Reason
            ManualEnvironments = $ManualEnvironments
            isDraft            = $IsDraft
            artifacts          = $_artifacts
        }
        If ($Variables)
        {
            $_variables = @{}
            Foreach ($token in $Variables.Keys)
            {
                $_variables.$token = @{
                    Value = $Variables.$token
                }
            }
            $body.Variables = $_variables
        }
        $apiEndpoint = Get-APApiEndpoint -ApiType 'release-releases'
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