function Update-APField
{
    <#
    .SYNOPSIS

    Updates an Azure Pipeline field in a work item type and process by field ref name.

    .DESCRIPTION

    Updates an Azure Pipeline field in a work item type and process by field ref name.
    The field ref name can be retrieved by using Get-APFieldList.
    The process id can be retrieved by using Get-APProcessList.
    Work item type reference name can be retrieved by using Get-APWorkItemTypeList

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

    .PARAMETER ProcessId

    The id of the process

    .PARAMETER WitRefName

    The reference name of the work item type.

    .PARAMETER FieldRefName

    The name of the field to update.

    .PARAMETER AllowGroups

    Allow setting field value to a group identity. Only applies to identity fields.

    .PARAMETER AllowedValues

    The list of field allowed values.

    .PARAMETER DefaultValue

    The default value of the field.

    .PARAMETER ReadOnly

    If true the field cannot be edited.

    .PARAMETER Required

    If true the field is required. 

    .INPUTS
    
    None, does not support the pipeline.

    .OUTPUTS

    PSObject, Azure Pipelines team(s)

    .EXAMPLE

    Updates an Azure Pipelines field to read only. 

    Update-APField -Instance 'https://dev.azure.com' -Collection 'myCollection' -ProcessId $process.TypeId -WitRefName $witType.referencename -FieldRefName $field.referencename -Required $false -ReadOnly $true 

    .LINK

    https://docs.microsoft.com/en-us/rest/api/azure/devops/processes/fields/update?view=azure-devops-rest-6.1
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
        [string]
        $ProcessId,

        [Parameter(Mandatory)]
        [string]
        $WitRefName,

        [Parameter(Mandatory)]
        [string]
        $FieldRefName, 

        [Parameter()]
        [bool]
        $AllowGroups,

        [Parameter()]
        [string[]]
        $AllowedValues,

        [Parameter()]
        [object]
        $DefaultValue,

        [Parameter()]
        [bool]
        $ReadOnly,

        [Parameter()]
        [bool]
        $Required
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
        $body = @{
        }
        If ($PSBoundParameters.ContainsKey('AllowGroups'))
        {
            $body.allowGroups = $AllowGroups
        }
        If ($PSBoundParameters.ContainsKey('AllowedValues'))
        {
            $body.allowedvalues = $AllowedValues
        }
        If ($PSBoundParameters.ContainsKey('DefaultValue'))
        {
            $body.defaultValue = $DefaultValue
        }
        If ($PSBoundParameters.ContainsKey('ReadOnly'))
        {
            $body.readOnly = $ReadOnly
        }
        If ($PSBoundParameters.ContainsKey('Required'))
        {
            $body.required = $Required
        }

        $apiEndpoint = (Get-APApiEndpoint -ApiType 'work-fieldname') -f $ProcessId, $WitRefName, $FieldRefName
        $setAPUriSplat = @{
            Collection  = $Collection
            Instance    = $Instance
            ApiVersion  = $ApiVersion
            ApiEndpoint = $apiEndpoint
        }
        [uri] $uri = Set-APUri @setAPUriSplat
        $invokeAPRestMethodSplat = @{
            Method              = 'PATCH'
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