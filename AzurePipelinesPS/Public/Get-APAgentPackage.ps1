Function Get-APAgentPackage
{
    <#
    .SYNOPSIS

    Returns available Azure Pipelines agent package versions.

    .DESCRIPTION

    Returns available Azure Pipelines agent package versions.
    The instance will provide a list of available compatible package versions and a url from which to download them.

    .PARAMETER Instance
    
    The Team Services account or TFS server.
    
    .PARAMETER Platform

    Operating system platform.

    .PARAMETER Credential

    Specifies a user account that has permission to send the request.
    
    .INPUTS

    None. You cannot pipe objects to Get-APAgentPackage.

    .OUTPUTS

    PSCustomObject. Get-APAgentPackage returns all compatable agent package versions.

    .EXAMPLE

    C:\PS> Get-APAgentPackage -Platform 'ubuntu.14.04-x64' -Credential $pscredential

    .EXAMPLE

    C:\PS> Get-APAgentPackage -Platform 'win7-x64'

    .LINK

    https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/agents?view=vsts
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter()]
        [string]
        $Instance = (Get-APModuleData).Instance,

        [Parameter(Mandatory)]
        [ValidateSet('win7-x64', 'ubuntu.16.04-x64', 'ubuntu.14.04-x64', 'rhel.7.2-x64', 'osx.10.11-x64')]
        [string]
        $Platform,

        [Parameter()]
        [pscredential]
        $Credential
    )
    Begin
    {
    }
    Process
    {
        $apiEndpoint = Get-APApiEndpoint -ApiType 'packages-agent'
        [uri] $uri = Set-APUri -Instance $Instance -ApiEndpoint $apiEndpoint -ApiVersion $ApiVersion
        $invokeAPRestMethodSplat = @{
            Method      = 'GET'
            Uri         = $uri
            Credential  = $Credential
        }
        $results = Invoke-APRestMethod @invokeAPRestMethodSplat
        Return $results.value
    }
}
