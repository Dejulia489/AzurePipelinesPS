[CmdletBinding()]
param
(
    $Task = 'Default'
)
$Script:Modules = @(
    @{
        Name       = 'InvokeBuild'
        Repository = 'PSGallery'
        Version    = 5.4.1
    },
    @{
        Name       = 'Pester'
        Repository = 'PSGallery'
        Version    = 4.4.0
    }
    @{
        Name       = 'PowerShellGet'
        Repository = 'PSGallery'
        Version    = 1.6.7
    },
    @{
        Name       = 'PackageManagement'
        Repository = 'PSGallery'
        Version    = 1.1.7.2
    }
)
$Script:ModuleInstallScope = 'CurrentUser'
Write-Output 'Starting build...'

Write-Output 'Installing module dependencies...'
Foreach ($module in $Modules)
{
    $installModuleSplat = @{
        MinimumVersion = $module.Version
        Name           = $module.Name
        Repository     = $module.Repository
        Scope          = $ModuleInstallScope
        Force          = $true 
        AllowClobber   = $true
    }
    Install-Module @installModuleSplat 
    Import-Module -Name $module.Name -Force
}

Write-Output 'Invoking build...'
Invoke-Build $Task -Result 'Result'
if ($Result.Error)
{
    $Error[-1].ScriptStackTrace | Out-String
    exit 1
}

exit 0
