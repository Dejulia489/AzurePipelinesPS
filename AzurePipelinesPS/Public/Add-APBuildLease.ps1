function Add-APBuildLease {
    <#
    .SYNOPSIS

    Creates an Azure Pipeline lease.

    .DESCRIPTION

    Creates an Azure Pipeline lease by build definition id.

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

    .PARAMETER DaysValid

    The number of days to consider the lease valid.

    .PARAMETER DefinitionId

    The pipeline definition of the run.

    .PARAMETER OwnerId

    User-provided string that identifies the owner of a retention lease.

    .PARAMETER ProtectPipeline

    If set, this lease will also prevent the pipeline from being deleted while the lease is still valid.

    .PARAMETER RunId

    The pipeline run to protect.

    .INPUTS

    None, does not support pipeline.

    .OUTPUTS

    PSObject, Azure Pipelines lease.

    .EXAMPLE


    .LINK

    https://learn.microsoft.com/en-us/rest/api/azure/devops/build/leases/add?view=azure-devops-rest-6.0
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
        [int]
        $DaysValid,

        [Parameter(Mandatory)]
        [int]
        $DefinitionId,

        [Parameter(Mandatory)]
        [string]
        $OwnerId,

        [Parameter(Mandatory)]
        [bool]
        $ProtectPipeline,

        [Parameter(Mandatory)]
        [int]
        $RunId
    )

    begin {
        If ($PSCmdlet.ParameterSetName -eq 'BySession') {
            $currentSession = $Session | Get-APSession
            If ($currentSession) {
                $Instance = $currentSession.Instance
                $Collection = $currentSession.Collection
                $Project = $currentSession.Project
                $PersonalAccessToken = $currentSession.PersonalAccessToken
                $Credential = $currentSession.Credential
                $Proxy = $currentSession.Proxy
                $ProxyCredential = $currentSession.ProxyCredential
                If ($currentSession.Version) {
                    $ApiVersion = (Get-APApiVersion -Version $currentSession.Version)
                }
                else {
                    $ApiVersion = $currentSession.ApiVersion
                }
            }
        }
    }

    process {
        $body = @(
            @{
                daysValid       = $DaysValid
                definitionId    = $DefinitionId
                ownerId         = $OwnerId
                protectPipeline = $ProtectPipeline
                runId           = $RunId
            }
        )
        $apiEndpoint = Get-APApiEndpoint -ApiType 'build-leases'
        $setAPUriSplat = @{
            Collection  = $Collection
            Instance    = $Instance
            Project     = $Project
            ApiVersion  = $ApiVersion
            ApiEndpoint = $apiEndpoint
        }
        [uri] $uri = Set-APUri @setAPUriSplat
        $invokeAPRestMethodSplat = @{
            Method              = 'POST'
            Uri                 = $uri
            Credential          = $Credential
            PersonalAccessToken = $PersonalAccessToken
            Body                = $body
            ContentType         = 'application/json'
            Proxy               = $Proxy
            ProxyCredential     = $ProxyCredential
        }
        $results = Invoke-APRestMethod @invokeAPRestMethodSplat 
        If ($results.value) {
            return $results.value
        }
        else {
            return $results
        }
    }

    end {
    }
}