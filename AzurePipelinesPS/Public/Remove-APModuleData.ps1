Function Remove-APModuleData
{
    <#
    .SYNOPSIS

    Removes module data that has been stored in the users local application data by Set-APModuleData.

    .DESCRIPTION

    Removes module data that has been stored in the users local application data by Set-APModuleData.
    The type of data removed depends on the parameters supplied to Remove-APModuleData.
    
    .LINK

    Get-APModuleData
    Set-APModuleData

    .PARAMETER Instance
    
    Removes instance from module data.

    .PARAMETER Collection
    
    Removes collection from module data.

    .PARAMETER Project
    
    Removes project from module data.    
    
    .PARAMETER PersonalAccessToken
    
    Removes personal access token from module data.

    .PARAMETER Version
    
    TFS version, this will provide the module with the api version mappings. 
    
    .PARAMETER Path
    
    The path where module data will be stored, defaults to $Script:ModuleDataPath      

    .INPUTS

    None. You cannot pipe objects to Remove-ModuleData.

    .OUTPUTS

    None. Remove-ModuleData returns nothing.

    .EXAMPLE

    C:\PS> Remove-ModuleData -Instance

    .EXAMPLE

    C:\PS> Remove-ModuleData -Collection -PersonalAccessToken
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter()]
        [Switch]
        $Instance,

        [Parameter()]
        [Switch]
        $Collection,

        [Parameter()]
        [Switch]
        $Project,

        [Parameter()]
        [Switch]
        $PersonalAccessToken,

        [Parameter()]
        [Switch]
        $Version,

        [Parameter()]
        [string]
        $Path = $Script:ModuleDataPath   
    )
    Process
    {
        $export = $false
        $moduleData = Get-APModuleData -Path $Path
        If ($Instance.IsPresent)
        {
            $moduleData.Instance = $null
            Write-Verbose "[$($MyInvocation.MyCommand.Name)]: Instance has been removed."
            $export = $true
        } 
        If ($Collection.IsPresent)
        {
            $moduleData.Collection = $null
            Write-Verbose "[$($MyInvocation.MyCommand.Name)]: Collection has been removed."
            $export = $true
        }   
        If ($Project.IsPresent)
        {
            $moduleData.Project = $null
            Write-Verbose "[$($MyInvocation.MyCommand.Name)]: Project has been removed."
            $export = $true
        }       
        If ($PersonalAccessToken.IsPresent)
        {
            $moduleData.PersonalAccessToken = $null
            Write-Verbose "[$($MyInvocation.MyCommand.Name)]: PersonalAccessToken has been removed."
            $export = $true
        }
        If ($Version.IsPresent)
        {
            $moduleData.Version = $null
            Write-Verbose "[$($MyInvocation.MyCommand.Name)]: Version has been removed."
            $export = $true
        }
        If (($Collection.IsPresent + $Project.IsPresent + $PersonalAccessToken.IsPresent + $Instance.IsPresent + $Version.IsPresent) -eq 0)
        {
            $moduleData.Instance = $null
            $moduleData.Collection = $null
            $moduleData.Project = $null
            $moduleData.PersonalAccessToken = $null
            $moduleData.Version = $null
            Write-Verbose "[$($MyInvocation.MyCommand.Name)]: Removing all module data."
        }
        If ($export)
        {
            $moduleData | Export-Clixml -Path $Path  -Force
            Write-Verbose "[$($MyInvocation.MyCommand.Name)]: Module data has been updated: [$Path]"    
        }
    }
}
