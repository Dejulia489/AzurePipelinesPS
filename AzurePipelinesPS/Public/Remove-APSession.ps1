Function Remove-APSession
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

    .PARAMETER Instance
    
    The Team Services account or TFS server.

    .LINK

    Save-APSession
    Remove-APModuleData

    .INPUTS

    None. You cannot pipe objects to Remove-APSession.

    .OUTPUTS

    PSObject. Remove-APSession returns a PSObject that contains the following:
        Instance
        Collection
        PersonalAccessToken

    .EXAMPLE

    C:\PS> Remove-APSession

    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName)]
        [int]
        $Id,
       
        [Parameter()]
        [string]
        $Path = $Script:ModuleDataPath  
    )
    Process
    {
        $session = Get-APSession -Id $Id
        If ($session.Saved -eq $true)
        {
            $newData = @{SessionData = @()}
            $data = Get-Content -Path $Path -Raw | ConvertFrom-Json
            Foreach ($_data in $data.SessionData)
            {
                If ($_data.Id -eq $session.Id)
                {
                    Continue
                }       
                else
                {
                    $newData.SessionData += $_data
                }
            }
            $newData | Convertto-Json -Depth 5 | Out-File -FilePath $Path
        }
        $Global:_APSessions = $Global:_APSessions | Where-Object {$PSItem.Id -ne $session.Id}
    }
}
