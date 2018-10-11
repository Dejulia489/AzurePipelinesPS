function Update-APVariableGroup
{
    <#
    .SYNOPSIS

    Modifies an Azure Pipeline variable group.

    .DESCRIPTION

    Modifies an Azure Pipeline variable group by group id.
    The id can be retrieved by using Get-APVariableGroupList.

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

    .PARAMETER GroupId

    Id of the variable group.

    .PARAMETER Session

    Azure DevOps PS session, created by New-APSession.

    .PARAMETER Description
    
    Sets description of the variable group.
 
    .PARAMETER Name
    
    Sets name of the variable group.

    .PARAMETER Variables
    
    Sets variables contained in the variable group.

    .INPUTS
    

    .OUTPUTS

    PSObject, Azure Pipelines variable group.

    .EXAMPLE

    $varibales = @{
        Var1 = 'updated val1'
        Var2 = 'updated val2'
        Var3 = 'updated val3'
    }
    $updateAPVariableGroupSplat = @{
        Description = 'my updated variable group'
        Name        = 'myUpdatedVariableGroup'
        Variables   = $varibales
        Instance    = 'https://myproject.visualstudio.com'
        Collection  = 'DefaultCollection'
        Project     = 'myFirstProject'
        GroupId     = 2
    }
    Update-APVariableGroup @updateAPVariableGroupSplat

    .LINK

    https://docs.microsoft.com/en-us/rest/api/vsts/distributedtask/variablegroups/update?view=vsts-rest-5.0
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

        [Parameter(Mandatory,
            ParameterSetName = 'BySession')]
        [object]
        $Session,

        [Parameter(Mandatory)]
        [int]
        $GroupId,

        [Parameter(Mandatory)]
        [string]
        $Name,

        [Parameter()]
        [string]
        $Description,

        [Parameter()]
        [object]
        $Variables
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
                $ApiVersion = (Get-APApiVersion -Version $currentSession.Version)
                $PersonalAccessToken = $currentSession.PersonalAccessToken
            }
        }
    }
    
    process
    {
        If($Variables.GetType().Name -eq 'hashtable')
        {
            $_variables = @{}
            Foreach ($token in $Variables.Keys)
            {
                $_variables.$token = @{
                    Value = $Variables.$token
                }
            }
        }
        else 
        {
            $_variables = $Variables    
        }
        $body = @{
            Name        = $Name
            Description = $Description
            Type        = 'Vsts'
            Variables   = $_variables
        }
        $apiEndpoint = (Get-APApiEndpoint -ApiType 'distributedtask-VariableGroupId') -f $GroupId
        $setAPUriSplat = @{
            Collection  = $Collection
            Instance    = $Instance
            Project     = $Project
            ApiVersion  = $ApiVersion
            ApiEndpoint = $apiEndpoint
        }
        [uri] $uri = Set-APUri @setAPUriSplat
        $invokeAPRestMethodSplat = @{
            Method              = 'PUT'
            Uri                 = $uri
            Credential          = $Credential
            PersonalAccessToken = $PersonalAccessToken
            Body                = $body
            ContentType         = 'application/json'
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