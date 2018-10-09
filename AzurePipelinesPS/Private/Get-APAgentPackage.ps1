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

    .PARAMETER Version
    
    TFS version, this will provide the module with the api version mappings. 

    .PARAMETER Credential

    Specifies a user account that has permission to send the request.
    
    .INPUTS

    None. You cannot pipe objects to Get-APAgentPackage.

    .OUTPUTS

    PSCustomObject. Get-APAgentPackage returns all compatable agent package versions.

    .EXAMPLE

    C:\PS> Get-APAgentPackage -Platform 'ubuntu.14.04-x64' -Credential $pscredential

    .EXAMPLE

    C:\PS> Get-APAgentPackage -Platform 'Windows'

    .LINK

    https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/agents?view=vsts
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter()]
        [string]
        $Instance,

        [Parameter(Mandatory)]
        [ValidateSet('Windows', 'ubuntu.16.04-x64', 'ubuntu.14.04-x64')]
        [string]
        $Platform,

        [Parameter()]
        [string]
        $ApiVersion,

        [Parameter()]
        [pscredential]
        $Credential
    )
    begin
    {
    }
    Process
    {

        Switch -Wildcard ($ApiVersion)
        {
            '*5.0*'
            {
                Switch ($Platform)
                {
                    'Windows'
                    {
                        Return 'https://vstsagentpackage.azureedge.net/agent/2.140.2/vsts-agent-win-x64-2.140.2.zip'
                    }
                    'ubuntu.16.04-x64'
                    {
                        Return 'https://vstsagentpackage.azureedge.net/agent/2.140.2/vsts-agent-linux-x64-2.140.2.tar.gz'
                    }
                    'ubuntu.14.04-x64'
                    {
                        Return 'https://vstsagentpackage.azureedge.net/agent/2.140.2/vsts-agent-linux-x64-2.140.2.tar.gz'
                    }
                }
            }
            Default
            {
                $apiEndpoint = Get-APApiEndpoint -ApiType 'packages-agent'
                [uri] $uri = Set-APUri -Instance $Instance -ApiEndpoint $apiEndpoint
                $invokeAPRestMethodSplat = @{
                    Method     = 'GET'
                    Uri        = $uri
                    Credential = $Credential
                }
                $results = Invoke-APRestMethod @invokeAPRestMethodSplat
                Switch ($Platform)
                {
                    'Windows'
                    {
                        Return $Results.Value | Where-Object {$Psitem.Platform -eq 'win7-x64'} | Select-Object -ExpandProperty 'downloadUrl'
                    }
                    'ubuntu.16.04-x64'
                    {
                        Return $Results.Value | Where-Object {$Psitem.Platform -eq 'ubuntu.16.04-x64'} | Select-Object -ExpandProperty 'downloadUrl'
                    }
                    'ubuntu.14.04-x64'
                    {
                        Return $Results.Value | Where-Object {$Psitem.Platform -eq 'ubuntu.14.04-x64'} | Select-Object -ExpandProperty 'downloadUrl'
                    }
                }
            }
        }
    }
}
