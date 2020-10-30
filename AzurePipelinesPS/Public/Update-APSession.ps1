Function Update-APSession
{
    <#
    .SYNOPSIS

    Updates an Azure Pipelines PS session.

    .DESCRIPTION

    Updates an Azure Pipelines PS session.
    The sensetive data is encrypted and stored in the users local application data.
    These updated sessions are available immediately.
    If the session was previously saved is will remain saved.

    .PARAMETER SessionName

    The friendly name of the session.

    .PARAMETER Id 

    The id of the session.

    .PARAMETER Instance

    The Team Services account or TFS server.

    .PARAMETER Collection

    For Azure DevOps the value for collection should be the name of your orginization. 
    For both Team Services and TFS The value should be DefaultCollection unless another collection has been created.
    See example 1.

    .PARAMETER Project

    Project ID or project name.

    .PARAMETER PersonalAccessToken

    Personal access token used to authenticate that has been converted to a secure string. 
    It is recomended to uses an Azure Pipelines PS session to pass the personal access token parameter among funcitons, See New-APSession.
    https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=vsts

    .PARAMETER Credential

    Specifies a user account that has permission to the project.

    .PARAMETER Version

    TFS version, this will provide the module with the api version mappings. 

    .PARAMETER ApiVersion
    
    Version of the api to use.

    .PARAMETER Proxy

    Use a proxy server for the request, rather than connecting directly to the Internet resource. Enter the URI of a network proxy server.

    .PARAMETER ProxyCredential

    Specifie a user account that has permission to use the proxy server that is specified by the -Proxy parameter. The default is the current user.

    .PARAMETER Path

    The path where module data will be stored, defaults to $Script:ModuleDataPath.

    .INPUTS

    PSbject. Get-APSession, New-APSession

    .OUTPUTS

    None. Update-APSession does not generate any output.

    .EXAMPLE
    
    Updates the AP session named 'myFirstSession' with the api version of '6.0-preview.1'

    Update-APSession -SessionName 'myFirstSession' -ApiVersion '6.0-preview.1'
    #>

    [CmdletBinding(DefaultParameterSetName = 'ByPersonalAccessToken')]
    Param
    (
        [Parameter(Mandatory)]
        [string]
        $SessionName,

        [Parameter()]
        [string]
        $Id,

        [Parameter()]
        [uri]
        $Instance,

        [Parameter()]
        [string]
        $Collection,

        [Parameter()]
        [string]
        $Project,

        [Parameter()]
        [ValidateSet('vNext', '2018 Update 2', '2018 RTW', '2017 Update 2', '2017 Update 1', '2017 RTW', '2015 Update 4', '2015 Update 3', '2015 Update 2', '2015 Update 1', '2015 RTW')]
        [Obsolete("[New-APSession]: Version has been deprecated and replaced with ApiVersion.")]
        [string]
        $Version,

        [Parameter(ParameterSetName = 'ByPersonalAccessToken')]
        [string]
        $PersonalAccessToken,

        [Parameter(ParameterSetName = 'ByCredential')]
        [pscredential]
        $Credential,

        [Parameter()]
        [string]
        $ApiVersion,

        [Parameter()]
        [string]
        $Proxy,

        [Parameter()]
        [pscredential]
        $ProxyCredential,

        [Parameter()]
        [string]
        $Path = $Script:ModuleDataPath
    )
    Begin
    {

    }
    Process
    {
        $getAPSessionSplat = @{
            SessionName = $SessionName
        }
        If ($Id)
        {
            $getAPSessionSplat.Id = $Id
        }
        $existingSessions = Get-APSession @getAPSessionSplat
        If ($existingSessions)
        {
            Foreach ($existingSession in $existingSessions)
            {
                $newAPSessionSplat = @{
                    SessionName = $SessionName
                }
                If ($Version)
                {
                    $newAPSessionSplat.Version = $Version
                }
                else
                {
                    If ($existingSession.Version)
                    {
                        $newAPSessionSplat.Version = $existingSession.Version
                    }
                }
                If ($ApiVersion)
                {
                    $newAPSessionSplat.ApiVersion = $ApiVersion
                }
                else
                {
                    If ($existingSession.ApiVersion)
                    {
                        $newAPSessionSplat.ApiVersion = $existingSession.ApiVersion
                    }
                }
                If ($Instance)
                {
                    $newAPSessionSplat.Instance = $Instance
                }
                else
                {
                    If ($existingSession.Instance)
                    {
                        $newAPSessionSplat.Instance = $existingSession.Instance
                    }
                }
                If ($Project)
                {
                    $newAPSessionSplat.Project = $Project
                }
                else
                {
                    If ($existingSession.Project)
                    {
                        $newAPSessionSplat.Project = $existingSession.Project
                    }
                }
                If ($Collection)
                {
                    $newAPSessionSplat.Collection = $Collection
                }
                else
                {
                    If ($existingSession.Collection)
                    {
                        $newAPSessionSplat.Collection = $existingSession.Collection
                    }
                }
                If ($PersonalAccessToken)
                {
                    $newAPSessionSplat.PersonalAccessToken = $PersonalAccessToken
                }
                else
                {
                    If ($existingSession.PersonalAccessToken)
                    {
                        $newAPSessionSplat.PersonalAccessToken = (Unprotect-APSecurePersonalAccessToken -PersonalAccessToken $existingSession.PersonalAccessToken)
                    }
                }
                If ($Credential)
                {
                    $_credentialObject = @{
                        Username = $Session.Credential.UserName
                        Password = ($Session.Credential.GetNetworkCredential().SecurePassword | ConvertFrom-SecureString)
                    }
                    $newAPSessionSplat.Credential = $_credentialObject
                }
                else
                {
                    If ($existingSession.Credential)
                    {
                        $newAPSessionSplat.Credential = $existingSession.Credential
                    }
                }
                If ($Proxy)
                {
                    $newAPSessionSplat.Proxy = $Session.Proxy
                }
                else
                {
                    If ($existingSession.Proxy)
                    {
                        $newAPSessionSplat.Proxy = $existingSession.Proxy
                    }
                }
                If ($ProxyCredential)
                {
                    $_proxyCredentialObject = @{
                        Username = $Session.ProxyCredential.UserName
                        Password = ($Session.ProxyCredential.GetNetworkCredential().SecurePassword | ConvertFrom-SecureString)
                    }
                    $newAPSessionSplat.ProxyCredential = $_proxyCredentialObject
                }
                else
                {
                    If ($existingSession.ProxyCredential)
                    {
                        $newAPSessionSplat.ProxyCredential = $existingSession.ProxyCredential
                    }
                }
                If ($existingSession.Saved)
                {
                    $existingSession | Remove-APSession -Path $Path
                    $session = New-APSession @newAPSessionSplat | Save-APSession
                }
                else
                {
                    $existingSession | Remove-APSession -Path $Path
                    $session = New-APSession @newAPSessionSplat
                }
            }
        }
        else
        {
            Write-Error "[$($MyInvocation.MyCommand.Name)]: Unable to locate an AP session with the name [$SessionName]." -ErrorAction Stop
        }
    }
    End
    {
    }
}
