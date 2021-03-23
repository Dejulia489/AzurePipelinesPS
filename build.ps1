[CmdletBinding()]
param
(
    [Parameter()]
    [string]
    $Task = 'Default',

    [Parameter()]
    [string]
    $moduleInstallScope = 'CurrentUser'
)
$modules = @(
    @{
        Name       = 'InvokeBuild'
        Repository = 'PSGallery'
        Version    = '5.4.1'
    }
    @{
        Name       = 'Pester'
        Repository = 'PSGallery'
        Version    = '4.4.0'
    }
    @{
        Name       = 'PSScriptAnalyzer'
        Repository = 'PSGallery'
        Version    = '1.18.1'
    }
)
Write-Host "[$($MyInvocation.MyCommand.Name)]: Starting build..."

Write-Host "[$($MyInvocation.MyCommand.Name)]: Checking module dependencies..."
Foreach ($module in $modules)
{
    Try
    {
        $installedModule = Get-InstalledModule -Name $module.Name -RequiredVersion $module.Version -ErrorAction 'Stop'
        Write-Host "[$($MyInvocation.MyCommand.Name)]: Located the installed module: [$($installedModule.Name)] - [$($installedModule.Version)]"
    }
    Catch
    {
        Write-Host "[$($MyInvocation.MyCommand.Name)]: Installing: [$($module.Name)] - [$($module.Version)] from [$($module.Repository)]"
        Install-Module -Name $module.Name -RequiredVersion $module.Version -Repository $module.Repository -Force -AllowClobber -SkipPublisherCheck -Scope $moduleInstallScope |
            Import-Module -Force
    }
}

Write-Host "[$($MyInvocation.MyCommand.Name)]: Invoking build..."
Invoke-Build $Task