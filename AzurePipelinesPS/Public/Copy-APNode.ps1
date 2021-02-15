function Copy-APNode
{
    <#
    .SYNOPSIS

    Copies an existing Azure Pipelines node. 

    .DESCRIPTION

    Copies an existing Azure Pipelines node by name or id.
    Return a list of nodes with Get-APNodeList.

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

    .PARAMETER TargetInstance

    The Team Services account or TFS server.

    .PARAMETER TargetCollection

    For Azure DevOps the value for collection should be the name of your orginization. 
    For both Team Services and TFS The value should be DefaultCollection unless another collection has been created.

    .PARAMETER TargetProject

    Project ID or project name.

    .PARAMETER TargetApiVersion

    Version of the api to use.

    .PARAMETER TargetPersonalAccessToken

    Personal access token used to authenticate that has been converted to a secure string. 
    It is recomended to uses an Azure Pipelines PS session to pass the personal access token parameter among funcitons, See New-APSession.
    https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=vsts

    .PARAMETER TargetCredential

    Specifies a user account that has permission to send the request.

    .PARAMETER TargetProxy

    Use a proxy server for the request, rather than connecting directly to the Internet resource. Enter the URI of a network proxy server.

    .PARAMETER TargetProxyCredential

    Specifie a user account that has permission to use the proxy server that is specified by the -Proxy parameter. The default is the current user.

    .PARAMETER TargetSession

    Azure DevOps PS session, created by New-APSession.

    .PARAMETER StructureGroup

    Structure group of the classification node. Options are areas or iterations.

    .PARAMETER Path

    Path of the classification node to copy.
    Do not include the name of the project or structure group in the path.

    .PARAMETER TargetPath

    The name target node path.
    Do not include the name of the project or structure group in the path.

    .PARAMETER Depth

    Depth of the children to fetch.

    .INPUTS

    None, does not support pipeline.

    .OUTPUTS

    PSObject, Azure Pipelines node.

    .EXAMPLE

    Copies the iteration node at path 'Iteration 1' to the target path 'Team 3'.

    Copy-APNode -Instance 'https://dev.azure.com' -Collection 'myCollection' -Project 'myFirstProject' -Path 'Iteration 1' -TargetPath 'Team 3' -Depth 2 -StructureGroup 'iterations'

    .EXAMPLE

    Copies all the iterations from 'myFirstProject' to the 'mySecondProject' in the same instance.

    Copy-APNode -Instance 'https://dev.azure.com' -Collection 'myCollection' -Project 'myFirstProject' -TargetProject 'mySecondProject' -Depth 3 -StructureGroup 'iterations'

    .LINK

    Get AP Node
    https://docs.microsoft.com/en-us/rest/api/azure/devops/core/nodes/get?view=azure-devops-rest-5.1

    Get AP Node Settings
    https://docs.microsoft.com/en-us/rest/api/azure/devops/work/nodesettings/get?view=azure-devops-rest-6.0
    
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

        [Parameter()]
        [uri]
        $TargetInstance,

        [Parameter()]
        [string]
        $TargetCollection,

        [Parameter()]
        [string]
        $TargetProject,

        [Parameter()]
        [string]
        $TargetApiVersion,

        [Parameter(ParameterSetName = 'ByPersonalAccessToken')]
        [Security.SecureString]
        $TargetPersonalAccessToken,

        [Parameter(ParameterSetName = 'ByCredential')]
        [pscredential]
        $TargetCredential,

        [Parameter()]
        [string]
        $TargetProxy,

        [Parameter()]
        [pscredential]
        $TargetProxyCredential,

        [Parameter()]
        [object]
        $TargetSession,

        [Parameter(Mandatory)]
        [string]
        $StructureGroup,

        [Parameter()]
        [string]
        $Path,

        [Parameter()]
        [object]
        $TargetPath,

        [Parameter()]
        [string]
        $Depth
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
            $currentTargetSession = $TargetSession | Get-APSession
            If ($currentTargetSession)
            {
                $TargetInstance = $currentTargetSession.Instance
                $TargetCollection = $currentTargetSession.Collection
                $TargetProject = $currentTargetSession.Project
                $TargetPersonalAccessToken = $currentTargetSession.PersonalAccessToken
                $TargetCredential = $currentTargetSession.Credential
                $TargetProxy = $currentTargetSession.Proxy
                $TargetProxyCredential = $currentTargetSession.ProxyCredential
                If ($currentTargetSession.Version)
                {
                    $TargetApiVersion = (Get-APApiVersion -Version $currentTargetSession.Version)
                }
                else
                {
                    $TargetApiVersion = $currentTargetSession.ApiVersion
                }
            }
        }
    }

    process
    {
        $sourceSplat = @{
            Instance        = $Instance
            Collection      = $Collection 
            ApiVersion      = $ApiVersion
            Project         = $Project
            Proxy           = $Proxy
            ProxyCredential = $ProxyCredential
            ErrorAction     = 'Stop'
            StructureGroup  = $StructureGroup
            Depth           = $Depth
        } 
        If ($PersonalAccessToken)
        {
            $sourceSplat.PersonalAccessToken = $PersonalAccessToken
        }
        If ($Credential)
        {
            $sourceSplat.Credential = $Credential
        }
        If ($Path)
        {
            $sourceSplat.Path = $Path
        }
        If (-not($TargetInstance))
        {
            $TargetInstance = $Instance
        }
        If (-not($TargetCollection))
        {
            $TargetCollection = $Collection
        }
        If (-not($TargetProject))
        {
            $TargetProject = $Project
        }
        If (-not($TargetApiVersion))
        {
            $TargetApiVersion = $ApiVersion
        }
        If (-not($TargetPersonalAccessToken))
        {
            $TargetPersonalAccessToken = $PersonalAccessToken
        }
        If (-not($TargetCredential))
        {
            $TargetCredential = $Credential
        }
        If (-not($TargetProxy))
        {
            $TargetProxy = $Proxy
        }
        If (-not($TargetProxyCredential))
        {
            $TargetProxyCredential = $ProxyCredential
        }
        $targetSplat = @{
            Instance        = $TargetInstance
            Collection      = $TargetCollection 
            Project         = $TargetProject
            ApiVersion      = $TargetApiVersion
            Proxy           = $TargetProxy
            ProxyCredential = $TargetProxyCredential
            ErrorAction     = 'Stop'
            StructureGroup  = $StructureGroup
        }
        If ($PersonalAccessToken)
        {
            $targetSplat.PersonalAccessToken = $TargetPersonalAccessToken
        }
        If ($Credential)
        {
            $targetSplat.Credential = $TargetCredential
        }
        [array] $nodes = Get-APNode @sourceSplat
        foreach ($node in $nodes)
        {
            foreach ($child in $node.children)
            {
                $split = $child.path.Split('\')
                $parsedPath = $split[3..($split.count - 1)] -join '\'
                $null = $PSBoundParameters.Remove('Path')
                $null = $PSBoundParameters.Remove('Depth')
                Copy-APNode @PSBoundParameters -Path $parsedPath -Depth ($Depth - 1)
            }
            $split = $node.path.Split('\')
            $parsedPath = $split[3..($split.count - 1)] -join '\'
            If ($TargetPath)
            {
                $_targetPath = "{0}\{1}" -f $TargetPath, $parsedPath
            }
            else
            {
                $_targetPath = $parsedPath
            }
            # Skip copying root node
            If ($split.count -le 3)
            {
                Continue
            }
            $_targetSpilt = $_targetPath.Split('\')
            for ($i = 0; $i -le $_targetSpilt.Count; $i++)
            {
                $_checkPath = $_targetSpilt[0..$i] -join '\'
                $_path = $_targetSpilt[0..($i - 1)] -join '\'
                $name = $_targetSpilt[$i]
                try
                {
                    $null = Get-APNode @targetSplat -Path $_checkPath
                    Continue
                }
                catch
                {
                    If ($PSItem.ErrorDetails.Message -match 'name is not recognized')
                    {
                        If ($i -eq 0)
                        {
                            New-APNode @targetSplat -Name $name -Attributes $node.attributes
                        }
                        else
                        {
                            New-APNode @targetSplat -Name $name -Path $_path -Attributes $node.attributes
                        }
                    }
                    else
                    {
                        $PSItem | Write-Error
                    }
                }
            }
        }
    }

    end
    {
    }
}