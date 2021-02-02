function Test-APPipelineYaml
{
    <#
    .SYNOPSIS

    Validates a local yaml pipeline file syntax.

    .DESCRIPTION

    Validates a local yaml pipeline file syntax.

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

    .PARAMETER Proxy
    
    Use a proxy server for the request, rather than connecting directly to the Internet resource. Enter the URI of a network proxy server.

    .PARAMETER ProxyCredential
    
    Specifie a user account that has permission to use the proxy server that is specified by the -Proxy parameter. The default is the current user.

    .PARAMETER Session

    Azure DevOps PS session, created by New-APSession.

    .PARAMETER PipelineId

    The id of an existing pipeline. 

    .PARAMETER FullName

    Path to the yaml file.

    .PARAMETER PipelineId

    The id of an existing pipeline. 

    .PARAMETER PipelineVersion

    The version of the pipeline to queue.

    .PARAMETER PreviewRun

    If true, don't actually create a new run. Instead returen the final YAML document after parsing templates.

    .PARAMETER Resources

    The resources the run requires.

    .PARAMETER StagesToSkip

    The stages to skip.

    .PARAMETER TemplateParameters

    Runtime parameters to pass to the pipeline.

    .PARAMETER Variables

    Pipeline variables.

    .PARAMETER YamlOverride

    If you use the preview run option, you may optionally supply different YAML. This allows you to preview the final YAML document without committing a changed file.

    .INPUTS

    None, does not support pipeline.

    .OUTPUTS

    None

    .EXAMPLE


    .LINK
    
    https://docs.microsoft.com/en-us/azure/devops/release-notes/2020/sprint-165-update#preview-fully-parsed-yaml-document-without-committing-or-running-the-pipeline
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

        [Parameter(ParameterSetName = 'ByPersonalAccessToken')]
        [Parameter(ParameterSetName = 'ByCredential')]
        [string]
        $Proxy,

        [Parameter(ParameterSetName = 'ByPersonalAccessToken')]
        [Parameter(ParameterSetName = 'ByCredential')]
        [pscredential]
        $ProxyCredential,

        [Parameter(Mandatory,
            ParameterSetName = 'BySession')]
        [object]
        $Session,

        [Parameter(Mandatory)]
        [int]
        $PipelineId,
        
        [Parameter()]
        [string]
        $FullName,

        [Parameter()]
        [string]
        $YamlOverride,

        [Parameter()]
        [string[]]
        $StagesToSkip,

        [Parameter()]
        [object]
        $Resources,

        [Parameter()]
        [hashtable]
        $TemplateParameters,

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
                $Proxy = $currentSession.Proxy
                $ProxyCredential = $currentSession.ProxyCredential
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
        If ($FullName)
        {
            $YamlOverride = Get-Content -Path $FullName
        }
        $splat = @{
            Instance            = $Instance
            Collection          = $Collection
            Project             = $Project
            ApiVersion          = $ApiVersion
            Proxy               = $Proxy
            ProxyCredential     = $ProxyCredential
            PreviewRun          = $true
            PipelineId          = $PipelineId
            YamlOverride        = $YamlOverride
            Resources           = $Resources
            StagesToSkip        = $StagesToSkip
            TemplateParameters  = $TemplateParameters
            Variables           = $Variables
        }
        If ($PersonalAccessToken)
        {
            $splat.PersonalAccessToken = $PersonalAccessToken
        }
        If ($Credential)
        {
            $splat.Credential = $Credential
        }
        Invoke-APPipeline @splat
    }
    
    end
    {
    }
}