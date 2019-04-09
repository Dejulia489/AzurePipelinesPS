Function Remove-APSession
{
    <#
    .SYNOPSIS

    Removes an Azure Pipelines PS session.

    .DESCRIPTION

    Removes an Azure Pipelines PS session.
    If the session is saved, it will be removed from the saved sessions as well.

    .PARAMETER Id
    
    Session id.

    .PARAMETER Path
    
    The path where session data will be stored, defaults to $Script:ModuleDataPath.

    .LINK

    Save-APSession
    Remove-APSession

    .INPUTS

    PSObject. Get-APSession

    .OUTPUTS

    PSObject. Remove-APSession returns a PSObject that contains the following:
        Instance
        Collection
        PersonalAccessToken

    .EXAMPLE

    Deletes AP session with the id of '2'.

    Remove-APSession -Id 2

    .EXAMPLE

    Deletes all AP sessions in memory and stored on disk.

    Remove-APSession

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
        $sessions = Get-APSession -Id $Id
        Foreach ($session in $sessions)
        {
            If ($session.Saved -eq $true)
            {
                $newData = @{SessionData = @() }
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
                $newData | ConvertTo-Json -Depth 5 | Out-File -FilePath $Path
            }
            $Global:_APSessions = $Global:_APSessions | Where-Object { $PSItem.Id -ne $session.Id }
        }
    }
}