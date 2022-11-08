function New-APNotificationSubscription
{
    <#
    .SYNOPSIS

    Creates a new notification subscription.

    .DESCRIPTION

    Creates a new notification subscription.

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

    .PARAMETER SubscriberFlags

    The flags that determine the type of notification delivery.

    .PARAMETER Template

    The template provided by Get-APNotificationSubscriptionList.

    .INPUTS
    
    None, does not support pipeline.

    .OUTPUTS

    PSObject, Azure Pipelines subscription list.

    .EXAMPLE
    
    Creates a 'build failure' subscription for a list of teams. The subscription will send a notification to the entire team if a build fails.

    # Gets a list of teams and outputs it to grid view, the grid view acts as pick list.
    $teams = (Get-APTeamList -Session $session | Out-GridView -PassThru)
    Foreach ($_team in $teams)
    {
        # Get the build fails notification subscription template.
        $template = Get-APNotificationSubscriptionTemplateList -Session $session | Where-Object { $PSitem.Description -match 'build fails' }

        # Add the team as the subscription subscriber to the template.
        $template | Add-Member -NotePropertyName 'Subscriber' -NotePropertyValue $_team

        # Add the teams project id as the scope id to the template.
        $template | Add-Member -NotePropertyName 'Scope' -NotePropertyValue @{ Id = $_team.ProjectId }

        # Add the channel type to the template.
        $template | Add-Member -NotePropertyName 'Channel' -NotePropertyValue @{type = 'Group'; useCustomAddress = $false }

        # Create the notification subscription from the template with the 'isTeam' flag.
        New-APNotificationSubscription -Session $session -Template $template -SubscriberFlags 'isTeam'
    }

    .EXAMPLE

    Creates a 'build failure' subscription for a list of teams. The subscription will send a notification to the members of the team's role. 
    Roles:
        Last changes by
        Requested by
        Requested for
        Deleted by

    # Gets a list of teams and outputs it to grid view, the grid view acts as pick list.
    $teams = (Get-APTeamList -Session $session | Out-GridView -PassThru)
    Foreach ($_team in $teams)
    {
        # Get the build fails notification subscription template.
        $template = Get-APNotificationSubscriptionTemplateList -Session $session | Where-Object { $PSitem.Description -match 'build fails' }
        
        # Add the team as the subscription subscriber to the template.
        $template | Add-Member -NotePropertyName 'Subscriber' -NotePropertyValue $_team
        
        # Add the teams project id as the scope id to the template.        
        $template | Add-Member -NotePropertyName 'Scope' -NotePropertyValue @{ Id = $_team.ProjectId }

        # Add the channel type to the template.
        $template | Add-Member -NotePropertyName 'Channel' -NotePropertyValue @{type = 'User'; useCustomAddress = $false }

        # Updates the filter from expression to 'Actor'.
        $template.Filter | Add-Member -NotePropertyName 'type' -NotePropertyValue 'Actor' -Force
        
        # Updates the filter inclusions to include the roles.
        $template.Filter | Add-Member -NotePropertyName 'inclusions' -NotePropertyValue @("lastChangedBy", "requestedBy", "requestedFor", "deletedBy") -Force

        # Updates the filter exclusions to exclude none.
        $template.Filter | Add-Member -NotePropertyName 'exclusions' -NotePropertyValue @() -Force

        # Create the notification subscription from the template with the 'isTeam' flag.
        New-APNotificationSubscription -Session $session -Template $template -SubscriberFlags 'isTeam'
    }

    .LINK

    https://docs.microsoft.com/en-us/rest/api/azure/devops/notification/subscriptions/get%20subscription%20templates?view=azure-devops-rest-5.0
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
        [ValidateSet('deliveryPreferencesEditable', 'isGroup', 'isTeam', 'isUser', 'none', 'supportsEachMemberDelivery', 'supportsNoDelivery', 'supportsPreferredEmailAddressDelivery')]
        [string]
        $SubscriberFlags,

        [Parameter(Mandatory)]
        [PSobject]
        $Template
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
        $Template | Add-Member -NotePropertyName 'SubscriberFlags' -NotePropertyValue $SubscriberFlags -Force
        $body = $Template
        $apiEndpoint = Get-APApiEndpoint -ApiType 'notification-subscriptions'
        $setAPUriSplat = @{
            Collection  = $Collection
            Instance    = $Instance
            ApiVersion  = $ApiVersion
            ApiEndpoint = $apiEndpoint
        }
        [uri] $uri = Set-APUri @setAPUriSplat
        $invokeAPRestMethodSplat = @{
            ContentType         = 'application/json'
            Body                = $body
            Method              = 'POST'
            Uri                 = $uri
            Credential          = $Credential
            PersonalAccessToken = $PersonalAccessToken
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