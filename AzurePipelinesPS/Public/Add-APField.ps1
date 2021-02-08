function Add-APField
{
    <#
    .SYNOPSIS

    Adds an Azure Pipeline field to a work item type and process.

    .DESCRIPTION

    Adds an Azure Pipeline field to a work item type and process.
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

    .PARAMETER AllowedGroups

    Allow setting field value to a group identity. Only applies to identity fields.

    .PARAMETER AllowedValues

    The list of field allowed values.

    .PARAMETER DefaultValue

    The default value of the field.

    .PARAMETER ReadOnly

    If true the field cannot be edited.

    .PARAMETER ReferenceName

    Reference name of the field.

    .PARAMETER Required

    If true the field cannot be empty.

    .INPUTS

    None, does not support pipeline.

    .OUTPUTS

    PSObject, Azure Pipelines field(s)

    .EXAMPLE

    Adds an AP field to a work item process.

    Add-APField -Session $session -ProcessId $process.TypeId -WitRefName 'Microsoft.VSTS.WorkItemTypes.Bug' -ReferenceName 'Custom.ReflectedWorkItemId' 

    .LINK

    https://docs.microsoft.com/en-us/rest/api/azure/devops/processes/fields/add?view=azure-devops-rest-6.1
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
        $ProcessId,

        [Parameter(Mandatory)]
        [string]
        $WitRefName,

        [Parameter()]
        [bool]
        $AllowedGroups,

        [Parameter()]
        [string[]]
        $AllowedValues, 

        [Parameter()]
        [string]
        $DefaultValue,

        [Parameter()]
        [bool]
        $ReadOnly,

        [Parameter()]
        [string]
        $ReferenceName,

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
            allowGroups   = $AllowedGroups
            allowedValues = $AllowedValues
            defaultValue  = $DefaultValue
            readOnly      = $ReadOnly
            referenceName = $ReferenceName
            required      = $Required
        }
        $apiEndpoint = (Get-APApiEndpoint -ApiType 'work-fields') -f $ProcessId, $WitRefName
        $queryParameters = Set-APQueryParameters -InputObject $PSBoundParameters
        $setAPUriSplat = @{
            Collection  = $Collection
            Instance    = $Instance
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