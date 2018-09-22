function Set-APUri
{    
    <#
    .SYNOPSIS

    Sets the uri used by Invoke-APRestMethod.

    .DESCRIPTION

    Sets the uri used by Invoke-APRestMethod.

    .PARAMETER Instance
    
    The Team Services account or TFS server.
    
    .PARAMETER Collection
    
    The value for collection should be DefaultCollection for both Team Services and TFS.

    .PARAMETER Project
    
    Project ID or project name

    .PARAMETER ApiEndpoint

    The api endpoint provided by Get-APApiEndpoint.

    .PARAMETER ApiVersion

    Version of the API to use.

    .OUTPUTS

    Uri, The uri that will be used by Invoke-APRestMethod.

    .EXAMPLE

    C:\PS> Set-APUri -Instance 'https://myproject.visualstudio.com' -Collection 'DefaultCollection' -ApiEndpoint _apis/Release/releases/4 -ApiVersion '5.0-preview.6'

    .LINK

    https://docs.microsoft.com/en-us/rest/api/vsts/?view=vsts-rest-5.0
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter()]
        [uri]
        $Instance = (Get-APModuleData).Instance,

        [Parameter()]
        [string]
        $Collection = (Get-APModuleData).Collection,

        [Parameter()]
        [string]
        $Project,

        [Parameter(Mandatory)]
        [string]
        $ApiEndpoint,

        [Parameter()]
        [string]
        $ApiVersion
    )

    begin
    {
    }

    process
    {   
        If ($Instance.AbsoluteUri -and $ApiEndpoint)
        {
            [uri] $output = '{0}{1}' -f $Instance.AbsoluteUri, $ApiEndpoint
        }
        else 
        {
            [uri] $output = '{0}{1}/{2}/{3}?api-version={4}' -f $Instance.AbsoluteUri, $Collection, $Project, $ApiEndpoint, $ApiVersion       
        }
    }

    end
    {
        Return $output
    }
}

