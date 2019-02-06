Function New-APSession
{
    <#
    .SYNOPSIS

    Creates an Azure Pipelines session.

    .DESCRIPTION

    Creates an Azure Pipelines session.
    Use Save-APSession to persist the session data to disk.
    Save the session to a variable to pass the session to other functions.

    .PARAMETER SessionName
    
    The friendly name of the session.

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

    .PARAMETER Name
    
    The friendly name of the mdoule data instance, configured by Save-APSession.

    .PARAMETER Path
    
    The path where module data will be stored, defaults to $Script:ModuleDataPath.

    .LINK

    Save-APSession
    Remove-APSession

    .INPUTS

    None, does not support pipeline.

    .OUTPUTS

    PSObject. New-APSession returns a PSObject that contains the following:
        Instance
        Collection
        PersonalAccessToken

    .EXAMPLE

    Creates a session with the name of 'AzurePipelinesPS' returning it to the $session variable.

    $newAPSessionSplat = @{
        Collection = 'myCollection'
        Project = 'myFirstProject'
        Instance = 'https://dev.azure.com/'
        PersonalAccessToken = 'myToken'
        Version = 'vNext'
        SessionName = 'AzurePipelinesPS'
    }
    $session = New-APSession @newAPSessionSplat 

    .EXAMPLE

    Creates a session with the name of 'myFirstSession' returning it to the $session variable. Then saves the session to disk for use after the session is closed.

    $newAPSessionSplat = @{
        Collection = 'myCollection'
        Project = 'myFirstProject'
        Instance = 'https://dev.azure.com/'
        PersonalAccessToken = 'myToken'
        Version = 'vNext'
        SessionName = 'myFirstSession'
    }
    $session = New-APSession @newAPSessionSplat
    $session | Save-APSession
    #>
    [CmdletBinding(DefaultParameterSetName = 'ByPersonalAccessToken')]
    Param
    (
        [Parameter(Mandatory)]
        [string]
        $SessionName,

        [Parameter(Mandatory)]
        [uri]
        $Instance,

        [Parameter(Mandatory)]
        [string]
        $Collection,

        [Parameter(Mandatory)]
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
        $Path = $Script:ModuleDataPath
    )
    Process
    {
        If ($Version)
        {
            $ApiVersion = Get-APApiVersion -Version $Version
        }
        If(-not($ApiVersion))
        {
            Write-Error "[$($MyInvocation.MyCommand.Name)]: ApiVersion is required to create a session" -ErrorAction 'Stop'
        }
        [int] $_sessionIdcount = (Get-APSession | Sort-Object -Property 'Id' | Select-Object -Last 1 -ExpandProperty 'Id') + 1
        $_session = New-Object -TypeName PSCustomObject -Property @{
            Instance    = $Instance
            Collection  = $Collection
            Project     = $Project
            ApiVersion  = $ApiVersion
            SessionName = $SessionName
            Id          = $_sessionIdcount
        }
        If ($PersonalAccessToken)
        {
            $securedPat = (ConvertTo-SecureString -String $PersonalAccessToken -AsPlainText -Force)
            $_session | Add-Member -NotePropertyName 'PersonalAccessToken' -NotePropertyValue $securedPat
        }
        If ($Credential)
        {
            $_session | Add-Member -NotePropertyName 'Credential' -NotePropertyValue $Credential
        }
        If ($null -eq $Global:_APSessions)
        {
            $Global:_APSessions = @()
        }
        $Global:_APSessions += $_session
        Return $_session
    }
}
