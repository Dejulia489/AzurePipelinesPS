Function Install-APAgent
{
    <#
    .SYNOPSIS

    Installs a Azure Pipelines agent on the server executing the function.

    .DESCRIPTION

    Installs a Azure Pipelines agent.
    The agent can be configured to listen to a pool or a deployment group.

    .PARAMETER Instance
    
    The Team Services account or TFS server.
    
    .PARAMETER Collection
    
    For Azure DevOps the value for collection should be the name of your orginization. 
    For both Team Services and TFS The value should be DefaultCollection unless another collection has been created.

    .PARAMETER Project
    
    Project ID or project name.

    .PARAMETER ApiVersion
    
    Version of the api to use.

    .PARAMETER Pool

    The pool name.

    .PARAMETER DeploymentGroupName

    The deployment group name.

    .PARAMETER DeploymentGroupTag

    The deployment group tags.

    .PARAMETER Platform

    Operating system platform.

    .PARAMETER PatAuthentication
    
    Authenticate with a personal access token.

    .PARAMETER IntegratedAuthentication
    
    Authenticate with a integrated credentials.

    .PARAMETER NegotiateAuthentication
    
    Authenticate with a negotiation, this requires a credential.

    .PARAMETER ProxyUrl
    
    The url of the proxy.

    .PARAMETER PersonalAccessToken
    
    Personal access token used to authenticate that has been converted to a secure string. 
    It is recomended to uses an Azure Pipelines PS session to pass the personal access token parameter among funcitons, See New-APSession.
    https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=vsts
    
    .PARAMETER Credential

    Specifies a user account that has permission to authenticate.
    
    .PARAMETER WindowsLogonCredential
    
    Specifies a user account that will run the windows service.

    .PARAMETER AgentWorkingFolder
    
    Agent's working directory, this must be unique to the agent, defaults to '_work'.    

    .PARAMETER RootAgentFolder
    
    The directory where the agent will be installed, defaults to 'Agents'.

    .INPUTS

    None. You cannot pipe objects to Install-APAgent.

    .OUTPUTS

    String. Install-APAgent returns log from configuration.

    .EXAMPLE

    C:\PS> Install-Agent -PatAuthentication -PersonalAccessToken 'myToken' -DeploymentGroupName 'Dev' -DeploymentGroupTag 'myTag' -Collection 'myCollection' -TeamProject 'AzurePipelinesPS' -Platform 'Windows'

    .EXAMPLE

    C:\PS> Install-Agent -NegotiateAuthentication -Credential $pscredential -Pool 'Default' -Collection 'myCollection' -TeamProject 'AzurePipelinesPS' -Platform 'Linux'

    .LINK

    https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/agents?view=vsts
    #>
    [CmdletBinding(DefaultParameterSetName = 'ByPersonalAccessToken')]
    Param
    (
        [Parameter(Mandatory)]
        [uri]
        $Instance,

        [Parameter(Mandatory)]
        [string]
        $Collection,

        [Parameter(Mandatory)]
        [string]
        $Project,

        [Parameter(Mandatory)]
        [string]
        $ApiVersion,

        [Parameter(ParameterSetName = "ByPatAuthenticationPool")]
        [Parameter(ParameterSetName = "ByPatAuthenticationDeploymentGroup")]
        [Security.SecureString]
        $PersonalAccessToken,

        [Parameter(Mandatory,
            ParameterSetName = "ByNegotiateAuthenticationPool")]
        [Parameter(Mandatory,
            ParameterSetName = "ByNegotiateAuthenticationDeploymentGroup")]
        [pscredential]
        $Credential,

        [Parameter(Mandatory,
            ParameterSetName = "ByPatAuthenticationPool")]
        [Parameter(Mandatory,
            ParameterSetName = "ByIntegratedAuthenticationPool")]
        [Parameter(Mandatory,
            ParameterSetName = "ByNegotiateAuthenticationPool")]
        [string]
        $Pool,

        [Parameter()]
        [string]
        [Parameter(Mandatory,
            ParameterSetName = "ByPatAuthenticationDeploymentGroup")]
        [Parameter(Mandatory,
            ParameterSetName = "ByIntegratedAuthenticationDeploymentGroup")]
        [Parameter(Mandatory,
            ParameterSetName = "ByNegotiateAuthenticationDeploymentGroup")]
        $DeploymentGroupName,

        [Parameter()]
        [string[]]
        $DeploymentGroupTag,

        [Parameter(Mandatory)]
        [ValidateSet('Windows', 'ubuntu.16.04-x64', 'ubuntu.14.04-x64')]
        [string]
        $Platform,

        [Parameter(ParameterSetName = "ByPatAuthenticationPool")]
        [Parameter(ParameterSetName = "ByPatAuthenticationDeploymentGroup")]
        [switch]
        $PatAuthentication,

        [Parameter(ParameterSetName = "ByIntegratedAuthenticationPool")]
        [Parameter(ParameterSetName = "ByIntegratedAuthenticationDeploymentGroup")]
        [switch]
        $IntegratedAuthentication,

        [Parameter(ParameterSetName = "ByNegotiateAuthenticationPool")]
        [Parameter(ParameterSetName = "ByNegotiateAuthenticationDeploymentGroup")]
        [switch]
        $NegotiateAuthentication,

        [Parameter(ParameterSetName = "ByPatAuthenticationPool")]
        [Parameter(ParameterSetName = "ByIntegratedAuthenticationPool")]
        [Parameter(ParameterSetName = "ByNegotiateAuthenticationPool")]
        [string]
        $ProxyUrl,

        [Parameter()]
        [pscredential]
        $WindowsLogonCredential,

        [Parameter()]
        [string]
        $AgentWorkingFolder = '_work',

        [Parameter()]
        [string]
        $RootAgentFolder = 'C:\vstsAgents'
    )

    $arguments = @(
        "--unattended"
        "--projectName `"{0}`"" -f $Project
        "--url $Instance$Collection"
        "--work `"{0}`"" -f $AgentWorkingFolder
        "--runasservice"
    )
    If ($Pool)
    {
        $arguments += "--pool `"{0}`"" -f $Pool
    }
    If ($DeploymentGroupName)
    {
        Write-Verbose "Configuring agent for deployment group: [$DeploymentGroupName]"
        $arguments += "--deploymentGroup"
        $arguments += "--deploymentGroupName `"{0}`"" -f $DeploymentGroupName
        If ($DeploymentGroupTag)
        {
            Write-Verbose ("Adding the following deployment tags: [{0}]" -f ($DeploymentGroupTag -join ', '))
            $arguments += "--addDeploymentGroupTags"
            $arguments += ("--deploymentGroupTags `"{0}`"" -f ($DeploymentGroupTag -join ', '))
        }
    }
    If ($WindowsLogonCredential.UserName)
    {
        Write-Verbose "Configuring the target agent to use a windows logon account: [$($WindowsLogonCredential.Username)]"
        $arguments += ("--windowsLogonAccount {0}" -f $WindowsLogonCredential.UserName)
        $arguments += ("--windowsLogonPassword `"{0}`"" -f $WindowsLogonCredential.GetNetworkCredential().Password)
    }
    If ($PatAuthentication)
    {
        $plainTextPat = Unprotect-APSecurePersonalAccessToken -PersonalAccessToken $PersonalAccessToken
        If (-not($plainTextPat))
        {
            Write-Error "[$($MyInvocation.MyCommand.Name)]: A personal access Token is required to use PAT authentications" -ErrorAction Stop
        }
        Write-Verbose "Authenticating using [PAT]"
        $arguments += "--auth Pat"
        $arguments += "--token $plainTextPat"
    }
    If ($IntegratedAuthentication)
    {
        Write-Verbose "Authenticating using [Integrated]"
        $arguments += "--auth integrated"
    }
    If ($NegotiateAuthentication)
    {
        Write-Verbose "Authenticating using [Negotiate]"
        $arguments += "--auth negotiate"
        $arguments += ("--userName {0}" -f $Credential.UserName)
        $arguments += ("--password {0}" -f $Credential.GetNetworkCredential().Password)
    }
    If ($ProxyUrl)
    {
        Write-Verbose "Using proxy url [$ProxyUrl]"
        $arguments += "--proxyurl $proxyUrl"
    }
    If (-not (Test-Path $RootAgentFolder))
    {
        Write-Verbose "Creating root agent path: [$RootAgentFolder]"  
        $null = New-Item -ItemType Directory -Path $RootAgentFolder
    }
    Set-Location $RootAgentFolder
    for ($i = 1; $i -lt 100; $i++)
    {
        $destFolder = 'A' + $i.ToString()
        if (-not (Test-Path ($destFolder)))
        {
            Write-Verbose "Creating destination folder: [$destFolder]"
            $null = New-Item -ItemType Directory -Path $destFolder
            Set-Location $destFolder
            break
        }
    }
    # Download agent
    $agentZip = "$PWD\agent.zip"
    $securityProtocol = @()
    $securityProtocol += [Net.ServicePointManager]::SecurityProtocol
    $securityProtocol += [Net.SecurityProtocolType]::Tls12
    [Net.ServicePointManager]::SecurityProtocol = $securityProtocol
    $WebClient = New-Object Net.WebClient
    $uri = Get-APAgentPackage -Platform $Platform -Instance $Instance -ApiVersion $ApiVersion
    If (-not($uri))
    {
        Write-Error "[$($MyInvocation.MyCommand.Name)]: Unable to locate package url!" -ErrorAction Stop
    }
    If ($ProxyUrl)
    {
        $WebClient.Proxy = New-Object Net.WebProxy($DefaultProxy.GetProxy($ProxyUrl), $True)
    }
    Write-Verbose "Downloading agent package from: [$uri]"
    $WebClient.DownloadFile($uri, $agentZip)
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    Write-Verbose "Extracting agent package"
    [System.IO.Compression.ZipFile]::ExtractToDirectory( $agentZip, "$PWD")
    Remove-Item $agentZip
    
    Write-Verbose "Configuring agent: [$arguments]"

    # Configure agent
    $arguments += "--agent {0}-{1}" -f $env:COMPUTERNAME, $destFolder
    $startprocessSplat = @{
        NoNewWindow            = $true
        Wait                   = $true
        FilePath               = "$RootAgentFolder\$destFolder\config.cmd"
        ArgumentList           = $arguments
        WorkingDirectory       = "$RootAgentFolder\$destFolder"
        RedirectStandardError  = 'errorResults.log'
        RedirectStandardOutput = 'results.log'
    }
    Start-Process @startprocessSplat
    Get-Content .\results.log
    $errorResults = Get-Content .\errorResults.log
    If ($errorResults)
    {
        Write-Error $errorResults
    }
}
