function Wait-APBuild
{
    <#
    .SYNOPSIS

    Waits for an Azure Pipelines build to exit 'inProgress' status.

    .DESCRIPTION

    Waits for an Azure Pipelines build to exit 'inProgress' status based on the build id.
    The id can be retrieved by using Get-APBuildList.

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

    .PARAMETER BuildId

    The ID of the build

    .PARAMETER Timeout
	
    Timeout threshold in seconds.

    .PARAMETER PollingInterval
	
    The number of seconds to wait before checking the status of the build, defaults to 1.

    .INPUTS
    
    None, does not support pipeline.

    .OUTPUTS

    PSObject, Azure Pipelines build(s)

    .EXAMPLE

    Waits for the build with the id of '7' for the 'myFirstProject.

    Wait-APBuild -Instance 'https://dev.azure.com' -Collection 'myCollection' -Project 'myFirstProject' -BuildId 7

    .EXAMPLE

    Waits for only 30 seconds for the build with the id of '9'.

    Wait-APBuild -Session 'mySession' -BuildId 7 -Timeout 30

    .LINK

    https://docs.microsoft.com/en-us/rest/api/vsts/build/builds/get?view=vsts-rest-5.0
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
        $BuildId,

        [Parameter()]
        [int]
        $Timeout = 300,

        [Parameter()]
        [int]
        $PollingInterval = 1
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
        $_timeout = (Get-Date).AddSeconds($TimeOut)
        $getAPBuildSplat = @{
            Collection = $Collection
            Instance   = $Instance
            BuildId    = $BuildId
            Project    = $Project
            ApiVersion = $ApiVersion
        }
        If ($PersonalAccessToken)
        {
            $getAPBuildSplat.PersonalAccessToken = $PersonalAccessToken
        }
        If ($Credential)
        {
            $getAPBuildSplat.Credential = $Credential
        }
        If ($Proxy)
        {
            $getAPBuildSplat.Proxy = $Proxy
        }
        If ($ProxyCredential)
        {
            $getAPBuildSplat.ProxyCredential = $ProxyCredential
        }
        Do
        {
            $buildData = Get-APBuild @getAPBuildSplat -ErrorAction 'Stop'
            If ($buildData.Status -eq 'inProgress')
            {
                Write-Verbose ("[{0}] Current status is: [$($buildData.Status)]. Sleeping for [$($PollingInterval)] seconds" -f (Get-Date -Format G))
                Start-Sleep -Seconds $PollingInterval
            }
            Else
            {
                Return $buildData
            }
        }
        Until ((Get-Date) -ge $_timeout)

        Write-Error "[$($MyInvocation.MyCommand.Name)]: Timed out after [$TimeOut] seconds. [$($buildData._links.web.href)]"
    }
    
    end
    {
    }
}