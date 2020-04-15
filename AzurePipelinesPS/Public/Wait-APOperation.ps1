function Wait-APOperation
{
    <#
    .SYNOPSIS

    Waits for an Azure Pipelines operation to exit 'inProgress' status.

    .DESCRIPTION

    Waits for an Azure Pipelines operation to exit 'inProgress' status based on the operation id.
    An operation id is returned by commands like New-APProject.

    .PARAMETER Instance
    
    The Team Services account or TFS server.
    
    .PARAMETER Collection
    
    For Azure DevOps the value for collection should be the name of your orginization. 
    For both Team Services and TFS The value should be DefaultCollection unless another collection has been created.

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

    .PARAMETER OperationId

    The ID of the operation

    .PARAMETER Timeout
	
    Timeout threshold in seconds.

    .PARAMETER PollingInterval
	
    The number of seconds to wait before checking the status of the operation, defaults to 1.

    .INPUTS
    
    None, does not support pipeline.

    .OUTPUTS

    PSObject, Azure Pipelines operation(s)

    .EXAMPLE

    Waits for the operation with the id of '7'.

    Wait-APOperation -Instance 'https://dev.azure.com' -Collection 'myCollection' -OperationId 7

    .EXAMPLE

    Waits for only 30 seconds for the operation with the id of '9'.

    Wait-APOperation -Session 'mySession' -OperationId 7 -Timeout 30

    .LINK

    https://docs.microsoft.com/en-us/rest/api/azure/devops/operations/operations/get?view=azure-devops-rest-5.1
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
        [string]
        $OperationId,

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
        $getAPOperationSplat = @{
            Collection  = $Collection
            Instance    = $Instance
            OperationId = $OperationId
            ApiVersion  = $ApiVersion
        }
        If ($PersonalAccessToken)
        {
            $getAPOperationSplat.PersonalAccessToken = $PersonalAccessToken
        }
        If ($Credential)
        {
            $getAPOperationSplat.Credential = $Credential
        }
        If ($Proxy)
        {
            $getAPOperationSplat.Proxy = $Proxy
        }
        If ($ProxyCredential)
        {
            $getAPOperationSplat.ProxyCredential = $ProxyCredential
        }
        Do
        {
            $operationData = Get-APOperation @getAPOperationSplat -ErrorAction 'Stop'
            If ($operationData.Status -eq 'inProgress' -or $operationData.Status -eq 'notStarted')
            {
                Write-Verbose ("[{0}] Current status is: [$($operationData.Status)]. Sleeping for [$($PollingInterval)] seconds" -f (Get-Date -Format G))
                Start-Sleep -Seconds $PollingInterval
            }
            Else
            {
                Return $operationData
            }
        }
        Until ((Get-Date) -ge $_timeout)

        Write-Error "[$($MyInvocation.MyCommand.Name)]: Timed out after [$TimeOut] seconds. [$($operationData._links.web.href)]"
    }
    
    end
    {
    }
}