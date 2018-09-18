Function Install-TFSAgent
{
    <#
    .SYNOPSIS

    Installs a Azure Pipelines agent

    .DESCRIPTION

    Adds a file name extension to a supplied name. Takes any strings for the
    file name or extension.

    .INPUTS

    None. You cannot pipe objects to Add-Extension.

    .OUTPUTS

    System.String. Add-Extension returns a string with the extension or
    file name.

    .EXAMPLE

    C:\PS> extension -name "File"
    File.txt

    .EXAMPLE

    C:\PS> extension -name "File" -extension "doc"
    File.doc

    .EXAMPLE

    Install 
    C:\PS> Install-Agent -PatAuthentication -PersonalAccessToken 'myToken' -Pool 'Default' -Collection 'DefaultCollection' -TeamProject 'AzurePipelinesPS' -Platform 'win7-x64'

    .LINK

    https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/agents?view=vsts
    #>
    [CmdletBinding(DefaultParameterSetName = "ByPatAuthenticationPool")]
    param
    (
        # Team project name
        [Parameter(Mandatory)]
        [string]
        $TeamProjectName,

        # Project collection name
        [Parameter(Mandatory)]
        [string]
        $ProjectCollectionName,

        # Pool name
        [Parameter(Mandatory,
            ParameterSetName = "ByPatAuthenticationPool")]
        [Parameter(Mandatory,
            ParameterSetName = "ByIntegratedAuthenticationPool")]
        [Parameter(Mandatory,
            ParameterSetName = "ByNegotiateAuthenticationPool")]
        [string]
        $Pool,

        # Deployment pool name
        [Parameter()]
        [string]
        [Parameter(Mandatory,
            ParameterSetName = "ByPatAuthenticationDeploymentGroup")]
        [Parameter(Mandatory,
            ParameterSetName = "ByIntegratedAuthenticationDeploymentGroup")]
        [Parameter(Mandatory,
            ParameterSetName = "ByNegotiateAuthenticationDeploymentGroup")]
        $DeploymentGroupName,

        # Deployment tags
        [Parameter()]
        [string[]]
        $DeploymentGroupTag,

        # Operating system platform
        [Parameter(Mandatory)]
        [ValidateSet('win7-x64', 'ubuntu.16.04-x64', 'ubuntu.14.04-x64', 'rhel.7.2-x64', 'osx.10.11-x64')]
        [string]
        $Platform,

        # Deployment pool name
        [Parameter(ParameterSetName = "ByPatAuthenticationPool")]
        [Parameter(ParameterSetName = "ByPatAuthenticationDeploymentGroup")]
        [switch]
        $PatAuthentication,

        # Deployment pool name
        [Parameter(ParameterSetName = "ByIntegratedAuthenticationPool")]
        [Parameter(ParameterSetName = "ByIntegratedAuthenticationDeploymentGroup")]
        [switch]
        $IntegratedAuthentication,

        # Deployment pool name
        [Parameter(ParameterSetName = "ByNegotiateAuthenticationPool")]
        [Parameter(ParameterSetName = "ByNegotiateAuthenticationDeploymentGroup")]
        [switch]
        $NegotiateAuthentication,

        # Pat token used to authenticate to TFS base uri
        [Parameter(ParameterSetName = "ByPatAuthenticationPool")]
        [Parameter(ParameterSetName = "ByPatAuthenticationDeploymentGroup")]
        [string]
        $PersonalAccessToken = (Get-TFSSecurePATToken),

        # Credential used to authenticate to TFS base uri
        [Parameter(Mandatory,
            ParameterSetName = "ByNegotiateAuthenticationPool")]
        [Parameter(Mandatory,
            ParameterSetName = "ByNegotiateAuthenticationDeploymentGroup")]
        [pscredential]
        $Credential,

        # Windows logon credential used to run the target agent
        [Parameter()]
        [pscredential]
        $WindowsLogonCredential,

        # Agent working folder
        [Parameter()]
        [string]
        $AgentWorkingFolder = '_work',

        # Root Agent folder
        [Parameter()]
        [string]
        $RootAgentFolder = 'Agents',

        # TFS base Uri
        [Parameter()]
        [string]
        $TFSBaseUri = ((Get-TFSModuleData).TFSBaseUri)
    )
    $arguments = @(
        "--unattended"
        "--projectName `"{0}`"" -f $TeamProjectName
        "--collectionName `"{0}`"" -f $ProjectCollectionName
        "--url $TfsBaseUri"
        "--work `"{0}`"" -f $AgentWorkingFolder
        "--runasservice"
    )
    If ($Pool)
    {
        $arguments += "--pool `"{0}`"" -f $Pool
    }
    If ($DeploymentGroupName)
    {
        Write-Verbose ("Configuring agent for a deployment group adding the following: [{0}]" -f ($DeploymentGroupTag -join ', '))
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
        If (-not($PersonalAccessToken))
        {
            Write-Error "A PAT Token is required to use PAT authentications, use 'Set-TFSServer -PAT' to store your token securely" -ErrorAction Stop
        }
        Write-Verbose "Authenticating using [PAT]"
        $arguments += "--auth Pat"
        $arguments += "--token $PersonalAccessToken"
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
    If (-not (Test-Path "$env:SystemDrive\$RootAgentFolder"))
    {
        Write-Verbose ("Creating root agent path: [{0}\{1}]" -f $env:SystemDrive, $RootAgentFolder)
        $null = New-Item -ItemType Directory -Path "$env:SystemDrive\$RootAgentFolder"
    }
    Set-Location "$env:SystemDrive\$RootAgentFolder"
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
    $DefaultProxy = [System.Net.WebRequest]::DefaultWebProxy
    $securityProtocol = @()
    $securityProtocol += [Net.ServicePointManager]::SecurityProtocol
    $securityProtocol += [Net.SecurityProtocolType]::Tls12
    [Net.ServicePointManager]::SecurityProtocol = $securityProtocol
    $WebClient = New-Object Net.WebClient
    $Uri = Get-TFSAgentPackage -Platform $Platform | Select-Object -ExpandProperty DownloadUrl | Select-Object -First 1
    If ($DefaultProxy -and (-not $DefaultProxy.IsBypassed($Uri)))
    {
        $WebClient.Proxy = New-Object Net.WebProxy($DefaultProxy.GetProxy($Uri).OriginalString, $True)
    }
    Write-Verbose "Downloading agent package from: [$Uri]"
    $WebClient.DownloadFile($Uri, $agentZip)
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    Write-Verbose "Extracting agent package"
    [System.IO.Compression.ZipFile]::ExtractToDirectory( $agentZip, "$PWD")
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
    Write-Verbose "Configuring agent for deployment group: [$DeploymentGroupName]"
    # Debug: Will output all arguments including passwords
    Write-Verbose "Arguments: [$arguments]"
    start-process @startprocessSplat
    Get-Content .\results.log
    $errorResults = Get-Content .\errorResults.log
    If ($errorResults)
    {
        Write-Error $errorResults
    }
    Remove-Item $agentZip
}
