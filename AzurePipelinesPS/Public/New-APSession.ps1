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
    
    The value for collection should be the name of your orginization. If you are using Team Services or TFS then the collection should be DefaultCollection.
    See example 1.

    .PARAMETER Project
    
    Project ID or project name.

    .PARAMETER PersonalAccessToken
    
    Personal access token used to authenticate that has been converted to a secure string. 
    It is recomended to uses an Azure Pipelines PS session to pass the personal access token parameter among funcitons, See New-APSession.
    https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=vsts
    
    .PARAMETER Version
    
    TFS version, this will provide the module with the api version mappings. 

    .PARAMETER Name
    
    The friendly name of the mdoule data instance, configured by Save-APSession.

    .PARAMETER Path
    
    The path where module data will be stored, defaults to $Script:ModuleDataPath.

    .LINK

    Save-APSession
    Remove-APModuleData

    .INPUTS

    None. You cannot pipe objects to New-APSession.

    .OUTPUTS

    PSObject. New-APSession returns a PSObject that contains the following:
        Instance
        Collection
        PersonalAccessToken

    .EXAMPLE

    C:\PS> New-APSession

    #>
    [CmdletBinding()]
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

        [Parameter(Mandatory)]
        [ValidateSet('vNext', '2018 Update 2', '2018 RTW', '2017 Update 2', '2017 Update 1', '2017 RTW', '2015 Update 4', '2015 Update 3', '2015 Update 2', '2015 Update 1', '2015 RTW')]
        [string]
        $Version,       

        [Parameter()]
        [string]
        $PersonalAccessToken,
        
        [Parameter()]
        [string]
        $Path = $Script:ModuleDataPath
    )
    Process
    {
        $_sessions = Get-APSession
        $sessionCount = $_sessions.Id.count
        $_session = New-Object -TypeName PSCustomObject -Property @{
            Instance            = $Instance
            Collection          = $Collection
            Project             = $Project
            Version             = $Version
            SessionName         = $SessionName
            Id                  = $sessionCount++
        }
        If ($PersonalAccessToken)
        {
            $securedPat = (ConvertTo-SecureString -String $PersonalAccessToken -AsPlainText -Force)
            $_session | Add-Member -NotePropertyName 'PersonalAccessToken' -NotePropertyValue $securedPat
        }
        If($null -eq $Global:_APSessions)
        {
            $Global:_APSessions = @()
        }
        $Global:_APSessions += $_session
        Return $_session
    }
}
