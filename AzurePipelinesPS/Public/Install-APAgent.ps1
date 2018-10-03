Function Install-APAgent {
    <#
    .SYNOPSIS

    Installs a Azure Pipelines agent on the server executing the function.

    .DESCRIPTION

    Installs a Azure Pipelines agent.
    The agent can be configured to listen to a pool or a deployment group.

    .PARAMETER Instance
    
    The Team Services account or TFS server.
    
    .PARAMETER Collection
    
    The value for collection should be DefaultCollection for both Team Services and TFS.

    .PARAMETER Project
    
    Project ID or project name.

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

    .PARAMETER PersonalAccessToken
    
    Personal access token used to authenticate. https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=vsts

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

    C:\PS> Install-Agent -PatAuthentication -PersonalAccessToken 'myToken' -DeploymentGroupName 'Dev' -DeploymentGroupTag 'myTag' -Collection 'DefaultCollection' -TeamProject 'AzurePipelinesPS' -Platform 'Windows'

    .EXAMPLE

    C:\PS> Install-Agent -NegotiateAuthentication -Credential $pscredential -Pool 'Default' -Collection 'DefaultCollection' -TeamProject 'AzurePipelinesPS' -Platform 'Linux'

    .LINK

    https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/agents?view=vsts
    #>
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param
    (
        [Parameter()]
        [string]
        $Instance = (Get-APModuleData).Instance,

        [Parameter()]
        [string]
        $Collection = (Get-APModuleData).Collection,

        [Parameter(Mandatory)]
        [string]
        $Project,

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
        [Parameter(ParameterSetName = "ByPatAuthenticationDeploymentGroup")]
        [string]
        $PersonalAccessToken,

        [Parameter(Mandatory,
            ParameterSetName = "ByNegotiateAuthenticationPool")]
        [Parameter(Mandatory,
            ParameterSetName = "ByNegotiateAuthenticationDeploymentGroup")]
        [pscredential]
        $Credential,

        [Parameter()]
        [pscredential]
        $WindowsLogonCredential,

        [Parameter()]
        [string]
        $AgentWorkingFolder = '_work',

        [Parameter()]
        [string]
        $RootAgentFolder = 'vstsAgents'
    )

    $arguments = @(
        "--unattended"
        "--projectName `"{0}`"" -f $Project
        "--url $Instance$Collection"
        "--work `"{0}`"" -f $AgentWorkingFolder
        "--runasservice"
    )
    If ($Pool) {
        $arguments += "--pool `"{0}`"" -f $Pool
    }
    If ($DeploymentGroupName) {
        Write-Verbose "Configuring agent for deployment group: [$DeploymentGroupName]"
        $arguments += "--deploymentGroup"
        $arguments += "--deploymentGroupName `"{0}`"" -f $DeploymentGroupName
        If ($DeploymentGroupTag) {
            Write-Verbose ("Adding the following deployment tags: [{0}]" -f ($DeploymentGroupTag -join ', '))
            $arguments += "--addDeploymentGroupTags"
            $arguments += ("--deploymentGroupTags `"{0}`"" -f ($DeploymentGroupTag -join ', '))
        }
    }
    If ($WindowsLogonCredential.UserName) {
        Write-Verbose "Configuring the target agent to use a windows logon account: [$($WindowsLogonCredential.Username)]"
        $arguments += ("--windowsLogonAccount {0}" -f $WindowsLogonCredential.UserName)
        $arguments += ("--windowsLogonPassword `"{0}`"" -f $WindowsLogonCredential.GetNetworkCredential().Password)
    }
    If ($PatAuthentication) {
        $PersonalAccessToken = Get-APSecurePersonalAccessToken
        If (-not($PersonalAccessToken)) {
            Write-Error "A PAT Token is required to use PAT authentications, use 'Set-TFSServer -PAT' to store your token securely" -ErrorAction Stop
        }
        Write-Verbose "Authenticating using [PAT]"
        $arguments += "--auth Pat"
        $arguments += "--token $PersonalAccessToken"
    }
    If ($IntegratedAuthentication) {
        Write-Verbose "Authenticating using [Integrated]"
        $arguments += "--auth integrated"
    }
    If ($NegotiateAuthentication) {
        Write-Verbose "Authenticating using [Negotiate]"
        $arguments += "--auth negotiate"
        $arguments += ("--userName {0}" -f $Credential.UserName)
        $arguments += ("--password {0}" -f $Credential.GetNetworkCredential().Password)
    }
    If (-not (Test-Path "$env:SystemDrive\$RootAgentFolder")) {
        Write-Verbose ("Creating root agent path: [{0}\{1}]" -f $env:SystemDrive, $RootAgentFolder)
        $null = New-Item -ItemType Directory -Path "$env:SystemDrive\$RootAgentFolder"
    }
    Set-Location "$env:SystemDrive\$RootAgentFolder"
    for ($i = 1; $i -lt 100; $i++) {
        $destFolder = 'A' + $i.ToString()
        if (-not (Test-Path ($destFolder))) {
            Write-Verbose "Creating destination folder: [$destFolder]"
            $null = New-Item -ItemType Directory -Path $destFolder
            Set-Location $destFolder
            break
        }
    }
    # Download agent
    $agentZip = "$PWD\agent.zip"
    $DefaultProxy = [System.Net.WebRequest]::DefaultWebProxy
    $securityProtocol = @()
    $securityProtocol += [Net.ServicePointManager]::SecurityProtocol
    $securityProtocol += [Net.SecurityProtocolType]::Tls12
    [Net.ServicePointManager]::SecurityProtocol = $securityProtocol
    $WebClient = New-Object Net.WebClient
    $Uri = Get-APAgentPackage -Platform $Platform 
    If ($DefaultProxy -and (-not $DefaultProxy.IsBypassed($Uri))) {
        $WebClient.Proxy = New-Object Net.WebProxy($DefaultProxy.GetProxy($Uri).OriginalString, $True)
    }
    Write-Verbose "Downloading agent package from: [$Uri]"
    $WebClient.DownloadFile($Uri, $agentZip)
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
        FilePath               = "$env:SystemDrive\$RootAgentFolder\$destFolder\config.cmd"
        ArgumentList           = $arguments
        WorkingDirectory       = "$env:SystemDrive\$RootAgentFolder\$destFolder"
        RedirectStandardError  = 'errorResults.log'
        RedirectStandardOutput = 'results.log'
    }
    Start-Process @startprocessSplat
    Get-Content .\results.log
    $errorResults = Get-Content .\errorResults.log
    If ($errorResults) {
        Write-Error $errorResults
    }
}
