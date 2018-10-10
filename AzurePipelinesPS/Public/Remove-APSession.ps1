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
