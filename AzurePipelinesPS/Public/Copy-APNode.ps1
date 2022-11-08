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

    .PARAMETER NodeId

    The id of the node to copy.

    .PARAMETER Path

    Path of the classification node to copy.
    Do not include the name of the project or structure group in the path.

    .PARAMETER TargetPath

    The name target node path.
    Do not include the name of the project or structure group in the path.

    .PARAMETER Depth

    Depth of the children to fetch.

    .PARAMETER UpdateExisting

    Will update the existing node.

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

    Get AP node
    https://docs.microsoft.com/en-us/rest/api/azure/devops/wit/classification%20nodes/get?view=azure-devops-rest-6.0

    Update AP node
    https://docs.microsoft.com/en-us/rest/api/azure/devops/wit/classification%20nodes/create%20or%20update?view=azure-devops-rest-6.0
    
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
        [string]
        $NodeId,

        [Parameter()]
        [object]
        $TargetPath,

        [Parameter()]
        [string]
        $Depth,

        [Parameter()]
        [switch]
        $UpdateExisting
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
        If ($NodeId)
        {
            [array] $nodes = Get-APNodeList @sourceSplat -Ids $NodeId
        }
        elseIf ($Path)
        {
            [array] $nodes = Get-APNode @sourceSplat -StructureGroup $StructureGroup -Path $Path
        }
        else
        {
            [array] $nodes = Get-APNode @sourceSplat -StructureGroup $StructureGroup
        }
        foreach ($node in $nodes)
        {
            foreach ($child in $node.children)
            {
                $null = $PSBoundParameters.Remove('Depth')
                $null = $PSBoundParameters.Remove('NodeId')
                Copy-APNode @PSBoundParameters -NodeId $child.Id -Depth ($Depth - 1)
            }
            $split = $node.path.Split('\')
            # Skip copying root node
            If ($split.count -le 3)
            {
                Continue
            }
            $parsedPath = $split[3..($split.count - 1)] -join '\'
            If ($TargetPath)
            {
                $_targetPath = "{0}\{1}" -f $TargetPath, $parsedPath
            }
            else
            {
                $_targetPath = $parsedPath
            }
            $_targetSpilt = $_targetPath.Split('\')
            for ($i = 0; $i -le ($_targetSpilt.Count - 1); $i++)
            {
                $name = $_targetSpilt[($i)]
                If ($i -eq 0)
                {
                    $exists = Get-APNode @targetSplat -Path $name -ErrorAction 'SilentlyContinue'
                    If ($exists)
                    {
                        If ($UpdateExisting.IsPresent)
                        {
                            Write-Verbose "[$($MyInvocation.MyCommand.Name)]: Updating [$name] in [$TargetProject]"
                            Update-APNode @targetSplat -Path $name -Attributes $node.attributes
                        }
                        else
                        {
                            Write-Verbose "[$($MyInvocation.MyCommand.Name)]: Located [$name] in [$TargetProject], Skipping."
                            Continue
                        }
                    }
                    else
                    {
                        Write-Verbose "[$($MyInvocation.MyCommand.Name)]: Creating [$name] in [$TargetProject]"
                        New-APNode @targetSplat -Name $name -Attributes $node.attributes
                    }
                }
                else
                {
                    $searchPath = $_targetSpilt[0..($i)] -join '\'
                    $_path = $_targetSpilt[0..($i - 1)] -join '\'
                    $exists = Get-APNode @targetSplat -Path $searchPath -ErrorAction 'SilentlyContinue'
                    If ($exists)
                    {
                        If ($UpdateExisting.IsPresent)
                        {
                            Write-Verbose "[$($MyInvocation.MyCommand.Name)]: Updating [$searchPath] in [$TargetProject]"
                            Update-APNode @targetSplat -Path $searchPath -Attributes $node.attributes
                        }
                        else
                        {
                            Write-Verbose "[$($MyInvocation.MyCommand.Name)]: Located [$searchPath] in [$TargetProject], Skipping."
                            Continue
                        }
                    }
                    else
                    {
                        Write-Verbose "[$($MyInvocation.MyCommand.Name)]: Creating [$_path\$name] in [$TargetProject]"
                        New-APNode @targetSplat -Name $name -Path $_path -Attributes $node.attributes
                    }
                }
            }
        }
    }

    end
    {
    }
}