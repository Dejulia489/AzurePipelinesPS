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
    
    Project ID or project name.

    .PARAMETER Query

    Url query parameter.

    .PARAMETER ApiEndpoint

    The api endpoint provided by Get-APApiEndpoint.    

    .PARAMETER ApiVersion

    Version of the api to use.

    .OUTPUTS

    Uri, The uri that will be used by Invoke-APRestMethod.

    .EXAMPLE

    C:\PS> Set-APUri -Instance 'https://myproject.visualstudio.com' -Collection 'DefaultCollection' -ApiEndpoint _apis/Release/releases/4 -ApiVersion '5.0-preview.6'

    .EXAMPLE

    C:\PS> Set-APUri -ApiEndpoint _apis/Release/releases/4 -ApiVersion '5.0-preview.6' -Query 'project=myFirstProject&isdeleted=true&expand=environments'

    .LINK

    https://docs.microsoft.com/en-us/rest/api/vsts/?view=vsts-rest-5.0
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
        $Project,

        [Parameter()]
        [string]
        $Query,

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
        If ($Instance.AbsoluteUri -and $Collection -and $Project -and ($ApiEndpoint -match 'release') -and ($ApiVersion -match '5.*') -and $Query)
        {
            # Append .vsrm prefix to instance if the api version is VNext and the api endpoint matches release with query
            [uri] $output = '{0}{1}/{2}/{3}?{4}&api-version={5}' -f $Instance.AbsoluteUri.replace($Instance.Host, "vsrm.$($Instance.Host)"), $Collection, $Project, $ApiEndpoint, $Query, $ApiVersion       
        }
        ElseIf ($Instance.AbsoluteUri -and $Collection -and $Project -and $ApiEndpoint -and $ApiVersion -and $Query)
        {
            [uri] $output = '{0}{1}/{2}/{3}?{4}&api-version={5}' -f $Instance.AbsoluteUri, $Collection, $Project, $ApiEndpoint, $Query, $ApiVersion       
        } 
        ElseIf ($Instance.AbsoluteUri -and $Collection -and $Project -and ($ApiEndpoint -match 'release') -and ($ApiVersion -match '5.*'))
        {
            # Append .vsrm prefix to instance if the api version is VNext and the api endpoint matches release without query
            [uri] $output = '{0}{1}/{2}/{3}?api-version={4}' -f $Instance.AbsoluteUri.replace($Instance.Host, "vsrm.$($Instance.Host)"), $Collection, $Project, $ApiEndpoint, $ApiVersion       
        }          
        ElseIf ($Instance.AbsoluteUri -and $Collection -and $Project -and $ApiEndpoint -and $ApiVersion)
        {
            [uri] $output = '{0}{1}/{2}/{3}?api-version={4}' -f $Instance.AbsoluteUri, $Collection, $Project, $ApiEndpoint, $ApiVersion       
        }  
        ElseIf ($Instance.AbsoluteUri -and $Collection -and $ApiEndpoint -and $ApiVersion)
        {
            [uri] $output = '{0}{1}/{2}?api-version={3}' -f $Instance.AbsoluteUri, $Collection, $ApiEndpoint, $ApiVersion 
        }      
        ElseIf ($Instance.AbsoluteUri -and $ApiEndpoint)
        {
            [uri] $output = '{0}{1}' -f $Instance.AbsoluteUri, $ApiEndpoint
        }
    }

    end
    {
        Return $output
    }
}

