Function Get-APModuleData
{
    <#
    .SYNOPSIS

    Returns module data that has been stored in the users local application data by Set-APModuleData.

    .DESCRIPTION

    Returns module data that has been stored in the users local application data by Set-APModuleData.
    The sensetive data is returned still encrypted.
    
    .PARAMETER Path
    
    The path where module data is stored, defaults to $Script:ModuleDataPath

    .PARAMETER Force
    
    Overrides the $Script:ModuleData variable regardles of whether or not it is already set.    

    .LINK

    Set-APModuleData
    Remove-APModuleData

    .INPUTS

    None. You cannot pipe objects to Get-APModuleData.

    .OUTPUTS

    PSObject. Get-APModuleData returns a PSObject that contains the following:
        Instance
        Collection
        PersonalAccessToken

    .EXAMPLE

    C:\PS> Get-APModuleData

    #>
    [CmdletBinding()]
    Param
    (
        [Parameter()]
        [string]
        $Path = $Script:ModuleDataPath,

        [Parameter()]
        [switch]
        $Force
    )
    Process
    {
        If (($Force.IsPresent) -or (-not($Script:ModuleData)))
        {
            If (Test-Path $Path)
            {
                $Script:moduleData = Import-Clixml -Path $Path -ErrorAction Stop
            }
            else
            {
                Write-Error "[$($MyInvocation.MyCommand.Name)]: Module data was not found: [$Path]! Run 'Set-APModuleData' to populate module data." -ErrorAction Stop
            }
            $Script:moduleData = @{
                Instance            = $moduleData.Instance
                Collection          = $moduleData.Collection
                Project             = $moduleData.Project
                PersonalAccessToken = $moduleData.PersonalAccessToken
                Version             = $moduleData.Version
            }
        }
        Write-Output -InputObject $Script:moduleData
    }
}
