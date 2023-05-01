function New-APField
{
    <#
    .SYNOPSIS

    Creates an Azure Pipeline field for a work item process.

    .DESCRIPTION

    Creates an Azure Pipeline field for a work item process.
    The process id can be retrieved by using Get-APProcessList.

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

    .PARAMETER Cansortby

    Indicates whether the field is sortable in server queries.

    .PARAMETER Description

    The description of the field.

    .PARAMETER Isdeleted

    Indicates whether this field is deleted.

    .PARAMETER Isidentity

    Indicates whether this field is an identity field.

    .PARAMETER Ispicklist

    Indicates whether this instance is picklist.

    .PARAMETER Ispicklistsuggested

    Indicates whether this instance is a suggested picklist .

    .PARAMETER Isqueryable

    Indicates whether the field can be queried in the server.

    .PARAMETER Name

    The name of the field.

    .PARAMETER Picklistid

    If this field is picklist, the identifier of the picklist associated, otherwise null

    .PARAMETER Readonly

    Indicates whether the field is [read only].

    .PARAMETER Referencename

    The reference name of the field.

    .PARAMETER Supportedoperations

    The supported operations on this field.

    .PARAMETER Type

    The type of the field.

    .PARAMETER Url

    the url of the field

    .PARAMETER Usage

    The usage of the field.

    .INPUTS

    None, does not support pipeline.

    .OUTPUTS

    PSObject, Azure Pipelines field(s)

    .EXAMPLE

    Creates an AP field for a work item process.

    New-APField -Session $session -ProcessId $process.TypeId -Description 'My new field' -Name 'Custom.MyNewField' -Type ''

    .LINK

    https://learn.microsoft.com/en-us/rest/api/azure/devops/wit/fields/create?view=azure-devops-rest-7.0
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
        [bool]
        $Cansortby,
        
        [Parameter()]
        [string]
        $Description,
        
        [Parameter()]
        [bool]
        $Isdeleted,
        
        [Parameter()]
        [bool]
        $Isidentity,
        
        [Parameter()]
        [bool]
        $Ispicklist,
        
        [Parameter()]
        [bool]
        $Ispicklistsuggested,
        
        [Parameter()]
        [bool]
        $Isqueryable,
        
        [Parameter(Mandatory)]
        [string]
        $Name,
        
        [Parameter()]
        [string]
        $Picklistid,
        
        [Parameter()]
        [bool]
        $Readonly,
        
        [Parameter()]
        [string]
        $Referencename,
        
        [Parameter()]
        [object]
        $Supportedoperations,
        
        [Parameter(Mandatory)]
        [ValidateSet('boolean', 'dateTime', 'double', 'guid', 'history', 'html', 'identity', 'integer', 'picklistDouble', 'picklistInteger', 'picklistString', 'plainText', 'string', 'treePath')]
        [string]
        $Type,
        
        [Parameter()]
        [string]
        $Url,
        
        [Parameter(Mandatory)]
        [validateSet('none', 'tree', 'workItem', 'workItemLink', 'workItemTypeExtension')]
        [string]
        $Usage
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
        $body = @{
            cansortby           = $Cansortby
            description         = $Description
            isdeleted           = $Isdeleted
            isidentity          = $Isidentity
            ispicklist          = $Ispicklist
            ispicklistsuggested = $Ispicklistsuggested
            isqueryable         = $Isqueryable
            name                = $Name
            picklistid          = $Picklistid
            readonly            = $Readonly
            referencename       = $Referencename
            supportedoperations = $Supportedoperations
            type                = $Type
            url                 = $Url
            usage               = $Usage
        }
        $apiEndpoint = Get-APApiEndpoint -ApiType 'wit-fields'
        $queryParameters = Set-APQueryParameters -InputObject $PSBoundParameters
        $setAPUriSplat = @{
            Collection  = $Collection
            Instance    = $Instance
            Project     = $Project
            ApiVersion  = $ApiVersion
            ApiEndpoint = $apiEndpoint
            Query       = $queryParameters
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
        If ($results.value)
        {
            return $results.value
        }
        else
        {
            return $results
        }
    }

    end
    {
    }
}