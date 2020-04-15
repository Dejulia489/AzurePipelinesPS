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

    .PARAMETER Session

    Azure DevOps PS session, created by New-APSession.

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

    .PARAMETER Proxy
    
    Use a proxy server for the request, rather than connecting directly to the Internet resource. Enter the URI of a network proxy server.

    .PARAMETER ProxyCredential
    
    Specifie a user account that has permission to use the proxy server that is specified by the -Proxy parameter. The default is the current user.

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

    None, does not support pipeline.

    .OUTPUTS

    String. Install-APAgent returns log from configuration.

    .EXAMPLE

    Installs a windows deployment group agent with PAT authentication.

    Install-Agent -PatAuthentication -PersonalAccessToken 'myToken' -DeploymentGroupName 'Dev' -DeploymentGroupTag 'myTag' -Collection 'myCollection' -TeamProject 'AzurePipelinesPS' -Platform 'Windows'

    .EXAMPLE

    Installs a linux pool agent with negotiation authentiaction.

    Install-Agent -NegotiateAuthentication -Credential $pscredential -Pool 'Default' -Collection 'myCollection' -TeamProject 'AzurePipelinesPS' -Platform 'Linux'

    .LINK

    https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/agents?view=vsts
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
        [Alias('ProxyUrl')]
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
        [ValidateSet('Windows', 'ubuntu.16.04-x64', 'ubuntu.14.04-x64')]
        [string]
        $Platform,

        [Parameter()]
        [switch]
        $PatAuthentication,

        [Parameter()]
        [switch]
        $IntegratedAuthentication,

        [Parameter()]
        [switch]
        $NegotiateAuthentication,

        [Parameter()]
        [string]
        $Pool,

        [Parameter()]
        [string]
        $DeploymentGroupName,

        [Parameter()]
        [string[]]
        $DeploymentGroupTag,

        [Parameter()]
        [pscredential]
        $WindowsLogonCredential,

        [Parameter()]
        [string]
        $AgentWorkingFolder = '_work',

        [Parameter()]
        [string]
        $RootAgentFolder = 'C:\agents'
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
        If ($Proxy)
        {
            Write-Verbose "Using proxy url [$Proxy]"
            $arguments += "--proxyurl $Proxy"
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
        If ($Proxy)
        {
            $DefaultProxy = [System.Net.WebRequest]::DefaultWebProxy
            $WebClient.Proxy = New-Object Net.WebProxy($DefaultProxy.GetProxy($Proxy), $True)
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
    end
    {

    }
}
