function Find-APPSModule
{
    <#
    .SYNOPSIS

    Finds a module from an Azure Pipelines feed.

    .DESCRIPTION

    Finds a module from an Azure Pipelines feed using the personal access token from the session configuration.

    .PARAMETER PersonalAccessToken
    
    Personal access token used to authenticate that has been converted to a secure string. 
    It is recomended to uses an Azure Pipelines PS session to pass the personal access token parameter among funcitons, See New-APSession.
    https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=vsts

    .PARAMETER Credential

    Specifies a user account that has permission to send the request.

    .PARAMETER Proxy
    
    Use a proxy server for the request, rather than connecting directly to the Internet resource. Enter the URI of a network proxy server.

    .PARAMETER ProxyCredential
    
    Specifie a user account that has permission to use the proxy server that is specified by the -Proxy parameter. The default is the current user.

    .PARAMETER Session

    Azure DevOps PS session, created by New-APSession.

    .PARAMETER Name

    pecifies the names of modules to search for in the repository. A comma-separated list of module names is accepted. Wildcards are accepted.

    .PARAMETER Repository

    Use the Repository parameter to specify which repository is used to download and install a module. Used when multiple repositories are registered. Specifies the name of a registered repository in the Install-APPSModule command. To register a repository, use Register-APPSRepository. To display registered repositories, use Get-PSRepository.

    .PARAMETER RequiredVersion

    Specifies the exact version of a single module to install. If there is no match in the repository for the specified version, an error is displayed. If you want to install multiple modules, you cannot use RequiredVersion.

    .PARAMETER AllVersions

    Specifies to include all versions of a module in the results. You cannot use the AllVersions parameter with the RequiredVersion parameters.

    .PARAMETER AllowPrerelease

    Includes in the results modules marked as a pre-release.

    .PARAMETER Command

    Specifies an array of commands to find in modules. A command can be a function or workflow.

    .PARAMETER DscResource

    Specifies the name, or part of the name, of modules that contain DSC resources. Per PowerShell conventions, performs an OR search when you provide multiple arguments.

    .PARAMETER Filter

    Specifies a filter based on the PackageManagement provider-specific search syntax. For NuGet modules, this parameter is the equivalent of searching by using the Search bar on the PowerShell Gallery website.

    .PARAMETER IncludeDependencies

    Indicates that this operation includes all modules that are dependent upon the module specified in the Name parameter.

    .PARAMETER AllVersions

    Specifies to include all versions of a module in the results. You cannot use the AllVersions parameter with the MinimumVersion, MaximumVersion, or RequiredVersion parameters.

    .PARAMETER MaximumVersion

    Specifies the maximum, or latest, version of the module to include in the search results. MaximumVersion and RequiredVersion cannot be used in the same command.

    .PARAMETER MinimumVersion

    Specifies the minimum version of the module to include in results. MinimumVersion and RequiredVersion cannot be used in the same command.

    .PARAMETER Tag

    Specifies an array of tags. Example tags include DesiredStateConfiguration, DSC, DSCResourceKit, or PSModule.

    .INPUTS
    
    None, does not support pipeline.

    .OUTPUTS

    PSObject, Azure Pipelines Module.

    .EXAMPLE
    
    .LINK

    https://docs.microsoft.com/en-us/powershell/module/powershellget/install-module?view=powershell-6
    #>
    [CmdletBinding(DefaultParameterSetName = 'ByPersonalAccessToken')]
    Param
    (
        [Parameter(Mandatory,
            ParameterSetName = 'ByPersonalAccessToken')]
        [Security.SecureString]
        $PersonalAccessToken,

        [Parameter(Mandatory,
            ParameterSetName = 'ByCredential')]
        [pscredential]
        $Credential,

        [Parameter(ParameterSetName = 'ByPersonalAccessToken')]
        [Parameter(ParameterSetName = 'ByCredential')]
        [string]
        $Proxy,

        [Parameter(ParameterSetName = 'ByPersonalAccessToken')]
        [Parameter(ParameterSetName = 'ByCredential')]
        [pscredential]
        $ProxyCredential,

        [Parameter(Mandatory,
            ParameterSetName = 'BySession')]
        [object]
        $Session,

        [Parameter(Mandatory)]
        [string[]]
        $Name,

        [Parameter()]
        [string[]]
        $Repository,

        [Parameter()]
        [string]
        $RequiredVersion,

        [Parameter()]
        [switch]
        $AllVersions,

        [Parameter()]
        [switch]
        $AllowPrerelease,

        [Parameter()]
        [string]
        $Command,

        [Parameter()]
        [string]
        $DscResource,
        
        [Parameter()]
        [string]
        $Filter,

        [Parameter()]
        [switch]
        $IncludeDependencies,

        [Parameter()]
        [string]
        $MaximumVersion,
        
        [Parameter()]
        [string]
        $MinimumVersion,

        [Parameter()]
        [string[]]
        $Tag
    )

    begin
    {
        If ($PSCmdlet.ParameterSetName -eq 'BySession')
        {
            $currentSession = $Session | Get-APSession
            If ($currentSession)
            {
                $PersonalAccessToken = $currentSession.PersonalAccessToken
                $Credential = $currentSession.Credential
                $Proxy = $currentSession.Proxy
                $ProxyCredential = $currentSession.ProxyCredential
            }
        }
    }
        
    process
    {
        If ($PersonalAccessToken)
        {
            $Credential = [pscredential]::new('NA', $PersonalAccessToken)
        }
        $findModuleSplat = @{
            Name       = $Name
            Credential = $Credential
        }
        If ($Repository)
        {
            $findModuleSplat.Repository = $Repository 
        }
        If ($Filter)
        {
            $findModuleSplat.Filter = $Filter 
        }
        If ($IncludeDependencies)
        {
            $findModuleSplat.IncludeDependencies = $IncludeDependencies 
        }
        If ($AllVersions)
        {
            $findModuleSplat.AllVersions = $AllVersions 
        }
        If ($AllowPrerelease)
        {
            $findModuleSplat.AllowPrerelease = $AllowPrerelease 
        }
        If ($Proxy)
        {
            $findModuleSplat.Proxy = $Proxy 
        }
        If ($ProxyCredential)
        {
            $findModuleSplat.ProxyCredential = $ProxyCredential 
        }
        If ($Command)
        {
            $findModuleSplat.Command = $Command 
        }
        If ($RequiredVersion)
        {
            $findModuleSplat.RequiredVersion = $RequiredVersion 
        }
        If ($MinimumVersion)
        {
            $findModuleSplat.MinimumVersion = $MinimumVersion 
        }
        If ($MaximumVersion)
        {
            $findModuleSplat.MaximumVersion = $MaximumVersion 
        }
        If ($DscResource)
        {
            $findModuleSplat.DscResource = $DscResource 
        }
        If ($Tag)
        {
            $findModuleSplat.Tag = $Tag 
        }
        Find-Module @findModuleSplat
    }
    
    end
    {
    }
}