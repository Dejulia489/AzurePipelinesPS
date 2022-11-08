function Install-APPSModule
{
    <#
    .SYNOPSIS

    Installs a module from an Azure Pipelines feed.

    .DESCRIPTION

    Installs a module from an Azure Pipelines feed using the personal access token from the session configuration.  
    A list of modules can be retrieved with Find-APPSModule.

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

    Specifies the exact names of modules to install from the online gallery. A comma-separated list of module names is accepted. The module name must match the module name in the repository. Use Find-APPSModule to get a list of module names.

    .PARAMETER Repository

    Use the Repository parameter to specify which repository is used to download and install a module. Used when multiple repositories are registered. Specifies the name of a registered repository in the Install-APPSModule command. To register a repository, use Register-APPSRepository. To display registered repositories, use Get-PSRepository.

    .PARAMETER Scope

    Specifies the installation scope of the module. The acceptable values for this parameter are AllUsers and CurrentUser.

    .PARAMETER RequiredVersion

    Specifies the exact version of a single module to install. If there is no match in the repository for the specified version, an error is displayed. If you want to install multiple modules, you cannot use RequiredVersion.

    .PARAMETER MaximumVersion

    Specifies the maximum, or latest, version of the module to include in the search results. MaximumVersion and RequiredVersion cannot be used in the same command.

    .PARAMETER MinimumVersion

    Specifies the minimum version of the module to include in results. MinimumVersion and RequiredVersion cannot be used in the same command.

    .PARAMETER AllowClobber

    Overrides warning messages about installation conflicts about existing commands on a computer. Overwrites existing commands that have the same name as commands being installed by a module.

    .PARAMETER SkipPublisherCheck

    Allows you to install a newer version of a module that already exists on your computer. For example, when an existing module is digitally signed by a trusted publisher but the new version is not digitally signed by a trusted publisher.

    .PARAMETER Force

    Installs a module and overrides warning messages about module installation conflicts. If a module with the same name already exists on the computer, Force allows for multiple versions to be installed. If there is an existing module with the same name and version, Force overwrites that version. 

    .PARAMETER AcceptLicense

    For modules that require a license, AcceptLicense automatically accepts the license agreement during installation. For more information, see Modules Requiring License Acceptance.

    .PARAMETER AllowPrerelease

    Includes in the results modules marked as a pre-release.
    
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
        [Parameter(ParameterSetName = 'ByPersonalAccessToken')]
        [Security.SecureString]
        $PersonalAccessToken,

        [Parameter(ParameterSetName = 'ByCredential')]
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
        [ArgumentCompleter( {
                param ( $commandName,
                    $parameterName,
                    $wordToComplete,
                    $commandAst,
                    $fakeBoundParameters )
                $possibleValues = Get-APSession | Select-Object -ExpandProperty SessionNAme
                $possibleValues.Where( { $PSitem -match $wordToComplete })
            })]
        [object]
        $Session,

        [Parameter(Mandatory)]
        [string[]]
        $Name,

        [Parameter()]
        [string[]]
        $Repository,

        [Parameter()]
        [ValidateSet('AllUsers', 'CurrentUser')]
        [string]
        $Scope,

        [Parameter()]
        [string]
        $RequiredVersion,

        [Parameter()]
        [string]
        $MinimumVersion,

        [Parameter()]
        [string]
        $MaximumVersion,

        [Parameter()]
        [switch]
        $AllowClobber,

        [Parameter()]
        [switch]
        $SkipPublisherCheck,

        [Parameter()]
        [switch]
        $Force,

        [Parameter()]
        [switch]
        $AllowPrerelease,

        [Parameter()]
        [switch]
        $AcceptLicense
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
        $installModuleSplat = @{
            Name       = $Name
            Credential = $Credential
        }
        If ($Repository)
        {
            $installModuleSplat.Repository = $Repository
        }
        If ($Scope)
        {
            $installModuleSplat.Scope = $Scope
        }
        If ($Proxy)
        {
            $installModuleSplat.Proxy = $Proxy
        }
        If ($ProxyCredential)
        {
            $installModuleSplat.ProxyCredential = $ProxyCredential
        }
        If ($SkipPublisherCheck)
        {
            $installModuleSplat.SkipPublisherCheck = $SkipPublisherCheck
        }
        If ($MinimumVersion)
        {
            $installModuleSplat.MinimumVersion = $MinimumVersion
        }
        If ($MaximumVersion)
        {
            $installModuleSplat.MaximumVersion = $MaximumVersion
        }
        If ($RequiredVersion)
        {
            $installModuleSplat.Scope = $RequiredVersion
        }
        If ($AllowPrerelease)
        {
            $installModuleSplat.AllowPrerelease = $AllowPrerelease
        }
        If ($AcceptLicense)
        {
            $installModuleSplat.AcceptLicense = $AcceptLicense
        }
        If ($AllowClobber)
        {
            $installModuleSplat.AllowClobber = $AllowClobber
        }
        If ($Force)
        {
            $installModuleSplat.Force = $Force
        }
        Install-Module @installModuleSplat
    }
    
    end
    {
    }
}