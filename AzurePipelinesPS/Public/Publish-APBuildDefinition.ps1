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
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    Param
    (
        [Parameter()]
        [uri]
        $Instance = (Get-APModuleData).Instance,

        [Parameter()]
        [string]
        $Collection = (Get-APModuleData).Collection,

        [Parameter()]
        [string]
        $Project = (Get-APModuleData).Project,

        [Parameter(ParameterSetName = 'ByQuery')]
        [int]
        $DefinitionToCloneId,

        [Parameter(ParameterSetName = 'ByQuery')]
        [int]
        $DefinitionToCloneRevision,

        [Parameter(ParameterSetName = 'ByQuery')]
        [bool]
        $ValidateProcessOnly,

        [Parameter(ParameterSetName = 'ByTemplate')]
        [PSobject]
        $Template,

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