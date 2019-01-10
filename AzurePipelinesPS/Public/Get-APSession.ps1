Function Get-APSession
{
    <#
    .SYNOPSIS

    Returns Azure Pipelines PS session data.

    .DESCRIPTION

    Returns Azure Pipelines PS session data that has been stored in the users local application data. 
    Use Save-APSession to persist the session data to disk.
    The sensetive data is returned encrypted.

    .PARAMETER Id
    
    Session id.

    .PARAMETER SessionName
    
    The friendly name of the session.

    .PARAMETER Path
    
    The path where session data will be stored, defaults to $Script:ModuleDataPath.

    .LINK

    Save-APSession
    Remove-APModuleData

    .INPUTS

    None, does not support pipeline.

    .OUTPUTS

    PSObject. Get-APSession returns a PSObject that contains the following:
        Instance
        Collection
        PersonalAccessToken

    .EXAMPLE

    Returns all AP sessions saved or in memory.

    Get-APSession

    .EXAMPLE

    Returns AP session with the session name of 'myFirstSession'.

    Get-APSession -SessionName 'myFirstSession'

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
        $_sessions = @()
        If (Test-Path $Path)
        {
            $data = Get-Content -Path $Path -Raw | ConvertFrom-Json           
            Foreach ($_data in $data.SessionData)
            {
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
        If ($null -ne $Global:_APSessions)
        {
            Foreach($_memSession in $Global:_APSessions)
            {
                If ($_sessions.Id -contains $_memSession.Id)
                {
                    Continue
                }
                Else
                {
                    $_sessions += $_memSession
                }
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