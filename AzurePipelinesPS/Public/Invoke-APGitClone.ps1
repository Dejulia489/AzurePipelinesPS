function Invoke-APGitClone
{
    <#
    .SYNOPSIS

    Invokes git clone of an Azure DevOps repository with an Azure DevOps personal access token

    .DESCRIPTION

    Invokes git clone of an Azure DevOps repository with an Azure DevOps personal access token

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
    
    .PARAMETER Path

    Path to clone the git repository.

    .PARAMETER Name
    
    A list of repository names to clone.

    .PARAMETER Interactive
    
    Provides a list of repositories to choose from.
    
    .INPUTS
    
    None, does not support pipeline.

    .OUTPUTS

    PSObject, Azure Pipelines approval(s)

    .EXAMPLE

    Clones all repositories from myFirstProject.

    Invoke-APGitClone -Instance 'https://dev.azure.com' -Collection 'myCollection' -Project 'myFirstProject' -ApiVersion 6.1-preview -Path 'c:\git\myCollection'

    .LINK

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
        [ArgumentCompleter( {
                param ( $commandName,
                    $parameterName,
                    $wordToComplete,
                    $commandAst,
                    $fakeBoundParameters )
                $possibleValues = Get-APSession | Select-Object -ExpandProperty SessionNAme
                $possibleValues.Where( { $PSitem -match $wordToComplete })
            })]
        [object]
        $Session,

        [Parameter(Mandatory)]
        [string]
        $Path,

        [Parameter()]
        [string[]]
        $Name,
        
        [Parameter()]
        [Switch]
        $Interactive      
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
        $splat = @{
            Collection = $Collection
            Instance   = $Instance
            Project    = $Project
            ApiVersion = $ApiVersion
        }
        If ($Credential)
        {
            $splat.Credential = $Credential
        }
        If ($PersonalAccessToken)
        {
            $splat.PersonalAccessToken = $PersonalAccessToken
        }
        If ($Proxy)
        {
            $splat.Proxy = $Proxy
        }
        If ($ProxyCredential)
        {
            $splat.ProxyCredential = $ProxyCredential
        }
        $pat = Unprotect-APSecurePersonalAccessToken -PersonalAccessToken $PersonalAccessToken
        $currentDir = Get-Location
        If(-not(Test-Path $Path))
        {
            $null = New-Item -Path $Path -ItemType Directory -Force 
        }
        Set-Location -Path $Path
        If($Interactive.IsPresent)
        {
            $repositories = Get-APRepositoryList @splat | Sort-Object -Property 'name' | Out-GridView -PassThru
        }
        ElseIf($PSBoundParameters.ContainsKey('Name'))
        {
            $repositories = Get-APRepositoryList @splat | Sort-Object -Property 'name' | Where-Object { $Name -contains $PSitem.Name }
        }
        Else
        {
            $repositories = Get-APRepositoryList @splat | Sort-Object -Property 'name' 
        }
        foreach ($repo in $repositories)
        {
            $url = [uri] $repo.remoteUrl
            $formattedUrl = '{0}://{1}{2}{3}{4}' -f $url.Scheme, $pat, '@', $url.Authority, $url.AbsolutePath
            git clone $formattedUrl
        }
        Set-Location $currentDir
    }
    
    end
    {
    }
}