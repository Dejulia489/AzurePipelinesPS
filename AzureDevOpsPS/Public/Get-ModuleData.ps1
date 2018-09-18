Function Get-ModuleData
{
    <#
    .SYNOPSIS

    Returns module data that has been stored in the users local application data by Set-ModuleData.

    .DESCRIPTION

    Returns module data that has been stored in the users local application data by Set-ModuleData.
    The sensetive data is returned still encrypted.
    
    .PARAMETER Path
    
    The path where module data is stored, defaults to $Script:ModuleDataPath

    .LINK

    Set-ModuleData
    Remove-ModuleData

    .INPUTS

    None. You cannot pipe objects to Get-ModuleData.

    .OUTPUTS

    PSCustomObject. Get-ModuleData returns a PSCustomObject that contains the following:
        Instance
        Collection
        PersonalAccessToken

    .EXAMPLE

    C:\PS> Get-ModuleData

    #>
    [CmdletBinding()]
    Param
    (
        [Parameter()]
        [string]
        $Path = $Script:ModuleDataPath
    )
    Process
    {
        If (Test-Path $Path)
        {
            $moduleData = Import-Clixml -Path $Path -ErrorAction Stop
        }
        else
        {
            Write-Error "[$($MyInvocation.MyCommand.Name)]: Module data was not found: [$Path]! Run the 'Set-ModuleData' command to populate module data." -ErrorAction Stop
        }
        $moduleData = @{
            Instance            = $moduleData.Instance
            Collection          = $moduleData.Collection
            PersonalAccessToken = $moduleData.PersonalAccessToken
        }
        Write-Output -InputObject $moduleData
    }
}
