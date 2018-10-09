Function Get-APSession
{
    <#
    .SYNOPSIS

    Returns module data that has been stored in the users local application data by Save-APSession.

    .DESCRIPTION

    Returns module data that has been stored in the users local application data by Save-APSession.
    The sensetive data is returned still encrypted.

    .PARAMETER Id
    
    Session id.

    .PARAMETER SessionName
    
    The friendly name of the session.

    .LINK

    Save-APSession
    Remove-APModuleData

    .INPUTS

    None. You cannot pipe objects to Get-APSession.

    .OUTPUTS

    PSObject. Get-APSession returns a PSObject that contains the following:
        Instance
        Collection
        PersonalAccessToken

    .EXAMPLE

    C:\PS> Get-APSession

    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(ParameterSetName = 'ById',
            ValueFromPipelineByPropertyName)]
        [int]
        $Id,

        [Parameter()]
        [string]
        $SessionName,

        [Parameter()]
        [string]
        $Path = $Script:ModuleDataPath
    )
    Process
    {
        If (-not($Global:_APSessions))
        {
            $Global:_APSessions = @()
        }
        $_sessions = $Global:_APSessions
        If (Test-Path $Path)
        {
            $data = Get-Content -Path $Path -Raw | ConvertFrom-Json           
            Foreach ($_data in $data.SessionData)
            {
                If ($_sessions.Id -contains $_data.Id)
                {
                    $_data | Remove-APSession
                }
                $_object = New-Object -TypeName PSCustomObject -Property @{
                    Id         = $_data.Id
                    Instance   = $_data.Instance
                    Collection = $_data.Collection
                    Project    = $_data.Project
                    SessionName = $_data.SessionName
                    Version    = $_data.Version
                    Saved      = $_data.Saved
                }
                If ($_data.PersonalAccessToken)
                {
                    $_object | Add-Member -NotePropertyName 'PersonalAccessToken' -NotePropertyValue ($_data.PersonalAccessToken | ConvertTo-SecureString)
                }
                $_sessions += $_object
            }
        }
        If ($PSCmdlet.ParameterSetName -eq 'ById')
        {
            $_sessions = $_sessions | Where-Object {$PSItem.Id -eq $Id}
        }
        If ($SessionName)
        {
            $_sessions = $_sessions | Where-Object {$PSItem.SessionName -eq $SessionName}
        }
        Return $_sessions
    }
}
