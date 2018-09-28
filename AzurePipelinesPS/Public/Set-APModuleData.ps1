Function Set-APModuleData
{
    <#
    .SYNOPSIS

    Generate module data used to set static values for certian parameters.

    .DESCRIPTION

    Generate module data used to set static values for certian parameters.
    The sensetive data is encrypted and stored in the users local application data.

    .PARAMETER Instance
    
    The Team Services account or TFS server. If you are using an Azure DevOps account be sure to include the 'vsrm.' prefix as part of the instance. 
    See example 1.
    
    .PARAMETER Collection
    
    The value for collection should be the name of your orginization. If you are using Team Services or TFS then the collection should be DefaultCollection.
    See example 1.

    .PARAMETER PersonalAccessToken
    
    Personal access token used to authenticate. https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=vsts

    .PARAMETER Version
    
    TFS version, this will provide the module with the api version mappings. 

    .PARAMETER Path
    
    The path where module data will be stored, defaults to $Script:ModuleDataPath.
    
    .INPUTS

    None. You cannot pipe objects to Set-APModuleData.

    .OUTPUTS

    None. Set-APModuleData returns nothing.

    .EXAMPLE
    
    If you are using an Azure DevOps instance you will need to include the 'vsrm.' prefix: 'https://vsrm.dev.azure.com/{myOrganization}'.
    C:\PS> Set-APModuleData -Instance 'https://vsrm.dev.azure.com/' -Collection 'myOrganization'

    .EXAMPLE

    C:\PS> Set-APModuleData -Instance 'https://myproject.visualstudio.com' -Collection 'DefaultCollection'

    .EXAMPLE

    C:\PS> Set-APModuleData -PersonalAccessToken 'myPatToken'

    .LINK

    Get-APModuleData
    Remove-APModuleData
    #>

    [CmdletBinding()]
    Param
    (
        [Parameter()]
        [uri]
        $Instance,

        [Parameter()]
        [string]
        $Collection,

        [Parameter()]
        [string]
        $PersonalAccessToken,

        [Parameter()]
        [ValidateSet('vNext', '2018 Update 2', '2018 RTW', '2017 Update 2', '2017 Update 1', '2017 RTW', '2015 Update 4', '2015 Update 3', '2015 Update 2', '2015 Update 1', '2015 RTW')]
        [string]
        $Version,        

        [Parameter()]
        [string]
        $Path = $Script:ModuleDataPath        
    )
    Process
    {
        $export = $false
        If (-not($Script:ModuleDataPath))
        {
            Write-Error "[$($MyInvocation.MyCommand.Name)] requires the global variable ModuleData that is populated during module import, please import the module." -ErrorAction Stop
        }
        If (-not(Test-Path $Path))
        {
            $null = New-Item -Path $Path -ItemType File -Force
            $null = Export-Clixml -Path $Path -InputObject @{}
        }
        $moduleData = Get-APModuleData -Path $Path
        If ($Instance)
        {
            If (-not($Instance.IsAbsoluteUri))
            {
                Write-Error "[$($MyInvocation.MyCommand.Name)]: [$Instance] is not a valid uri" -ErrorAction Stop
            }
            $moduleData.Instance = $Instance.AbsoluteUri
            Write-Verbose "[$($MyInvocation.MyCommand.Name)]: Instance has been set to [$($Instance.AbsoluteUri)]"
            $export = $true
        }        
        If ($PersonalAccessToken)
        {
            $securedPat = (ConvertTo-SecureString -String $PersonalAccessToken -AsPlainText -Force)
            $moduleData.PersonalAccessToken = $securedPat
            Write-Verbose "[$($MyInvocation.MyCommand.Name)]: PersonalAccessToken has been set"
            $export = $true
        }
        If ($Collection)
        {
            $moduleData.Collection = $Collection
            Write-Verbose "[$($MyInvocation.MyCommand.Name)]: Collection has been set to [$Collection]"
            $export = $true
        }
        If ($Version)
        {
            $moduleData.Version = $Version
            Write-Verbose "[$($MyInvocation.MyCommand.Name)]: Version has been set to [$Version]"
            $export = $true
        }
        If ($export)
        {
            $moduleData | Export-Clixml -Path $Path  -Force
            Write-Verbose "[$($MyInvocation.MyCommand.Name)]: Module data has been stored: [$PathPath]"
        }
    }
}
