Function Remove-ModuleData
{
    <#
    .SYNOPSIS

    Removes module data that has been stored in the users local application data by Set-ModuleData.

    .DESCRIPTION

    Removes module data that has been stored in the users local application data by Set-ModuleData.
    The type of data removed depends on the parameters supplied to Remove-ModuleData.
    
    .LINK

    Get-ModuleData
    Set-ModuleData

    .PARAMETER Instance
    
    Remove instance from module data

    .PARAMETER Collection
    
    Remove collection from module data
    
    .PARAMETER PersonalAccessToken
    
    Remove personal access token from module data

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
        $PersonalAccessToken,

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
        If ($PersonalAccessToken.IsPresent)
        {
            $moduleData.PersonalAccessToken = $null
            Write-Verbose "[$($MyInvocation.MyCommand.Name)]: PersonalAccessToken has been removed."
            $export = $true
        }
        If (-not($Collection.IsPresent -and $PersonalAccessToken.IsPresent -and $Instance.IsPresent))
        {
            $moduleData.Instance = $null
            $moduleData.Collection = $null
            $moduleData.PersonalAccessToken = $null
            Write-Verbose "[$($MyInvocation.MyCommand.Name)]: Removing all module data."
        }
        If ($export)
        {
            $moduleData | Export-Clixml -Path $Path  -Force
            Write-Verbose "[$($MyInvocation.MyCommand.Name)]: Module data has been updated: [$Path]"    
        }
    }
}
