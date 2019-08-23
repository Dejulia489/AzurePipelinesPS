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

    For Azure DevOps the value for collection should be the name of your orginization.
    For both Team Services and TFS The value should be DefaultCollection unless another collection has been created.

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

    Set-APUri -Instance 'https://dev.azure.com' -Collection 'myCollection' -ApiEndpoint _apis/Release/releases/4 -ApiVersion '5.0-preview.6'

    .EXAMPLE

    Set-APUri -ApiEndpoint _apis/Release/releases/4 -ApiVersion '5.0-preview.6' -Query 'project=myFirstProject&isdeleted=true&expand=environments'

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
        If ($ApiVersion -match '5.*' -and ($Instance.Host -eq 'dev.azure.com' -or $Instance.Host -like '*.visualstudio.com'))
        {
            # Api endpoint matches release
            If ($ApiEndpoint -match 'release')
            {
                If ($Instance.AbsoluteUri -and $Collection -and $Project -and $Query)
                {
                    # Append vsrm prefix to instance with query
                    return '{0}{1}/{2}/{3}?{4}&api-version={5}' -f $Instance.AbsoluteUri.replace($Instance.Host, "vsrm.$($Instance.Host)"), $Collection, $Project, $ApiEndpoint, $Query, $ApiVersion
                }
                ElseIf ($Instance.AbsoluteUri -and $Collection -and $Project)
                {
                    # Append vsrm prefix to instance without query
                    return '{0}{1}/{2}/{3}?api-version={4}' -f $Instance.AbsoluteUri.replace($Instance.Host, "vsrm.$($Instance.Host)"), $Collection, $Project, $ApiEndpoint, $ApiVersion
                }
            }
            # Api endpoint matches feeds
            If ($ApiEndpoint -match 'feeds')
            {
                If ($ApiEndpoint -match 'versions')
                {
                    # Append pkgs prefix to instance with query
                    return '{0}{1}/{2}/{3}?{4}&api-version={5}' -f $Instance.AbsoluteUri.replace($Instance.Host, "pkgs.$($Instance.Host)"), $Collection, $Project, $ApiEndpoint, $Query, $ApiVersion
                }
                If ($Instance.AbsoluteUri -and $Collection -and $Query)
                {
                    # Append feeds prefix to instance with query
                    return '{0}{1}/{2}/{3}?{4}&api-version={5}' -f $Instance.AbsoluteUri.replace($Instance.Host, "feeds.$($Instance.Host)"), $Collection, $Project, $ApiEndpoint, $Query, $ApiVersion
                }
                ElseIf ($Instance.AbsoluteUri -and $Collection)
                {
                    # Append feeds prefix to instance without query
                    return '{0}{1}/{2}/{3}?api-version={4}' -f $Instance.AbsoluteUri.replace($Instance.Host, "feeds.$($Instance.Host)"), $Collection, $Project, $ApiEndpoint, $ApiVersion
                }
            }
            # Api endpoint matches graph
            If ($ApiEndpoint -match 'graph')
            {
                If ($Instance.AbsoluteUri -and $Collection -and $Query)
                {
                    # Append vssps prefix to instance with query
                    return '{0}{1}/{2}/{3}?{4}&api-version={5}' -f $Instance.AbsoluteUri.replace($Instance.Host, "vssps.$($Instance.Host)"), $Collection, $Project, $ApiEndpoint, $Query, $ApiVersion
                }
                ElseIf ($Instance.AbsoluteUri -and $Collection)
                {
                    # Append vssps prefix to instance without query
                    return '{0}{1}/{2}/{3}?api-version={4}' -f $Instance.AbsoluteUri.replace($Instance.Host, "vssps.$($Instance.Host)"), $Collection, $Project, $ApiEndpoint, $ApiVersion
                }
            }
            # Api endpoint matches tokenadmin
            If ($ApiEndpoint -match 'tokenadmin')
            {
                If ($Instance.AbsoluteUri -and $Collection -and $Query)
                {
                    # Append vssps prefix to instance with query
                    return '{0}{1}/{2}?{3}&api-version={4}' -f $Instance.AbsoluteUri.replace($Instance.Host, "vssps.$($Instance.Host)"), $Collection, $ApiEndpoint, $Query, $ApiVersion
                }
                ElseIf ($Instance.AbsoluteUri -and $Collection)
                {
                    # Append vssps prefix to instance without query
                    return '{0}{1}/{2}?api-version={3}' -f $Instance.AbsoluteUri.replace($Instance.Host, "vssps.$($Instance.Host)"), $Collection, $ApiEndpoint, $ApiVersion
                }
            }
            # Api endpoint matches groupentitlements
            If ($ApiEndpoint -match 'groupentitlements')
            {
                If ($Instance.AbsoluteUri -and $Collection)
                {
                    # Append vsaex prefix to instance without query
                    return '{0}{1}/{2}/{3}?api-version={4}' -f $Instance.AbsoluteUri.replace($Instance.Host, "vsaex.$($Instance.Host)"), $Collection, $Project, $ApiEndpoint, $ApiVersion
                }
            }
            # Api endpoint matches extensionmanagement
            If ($ApiEndpoint -match 'extensionmanagement')
            {
                If ($Instance.AbsoluteUri -and $Collection -and $Query)
                {
                    # Append extmgmt prefix to instance with query
                    return '{0}{1}/{2}/{3}?{4}&api-version={5}' -f $Instance.AbsoluteUri.replace($Instance.Host, "extmgmt.$($Instance.Host)"), $Collection, $Project, $ApiEndpoint, $Query, $ApiVersion
                }
                ElseIf ($Instance.AbsoluteUri -and $Collection)
                {
                    # Append extmgmt prefix to instance without query
                    return '{0}{1}/{2}/{3}?api-version={4}' -f $Instance.AbsoluteUri.replace($Instance.Host, "extmgmt.$($Instance.Host)"), $Collection, $Project, $ApiEndpoint, $ApiVersion
                }
            }
            # Api endpoint matches packaging
            If ($ApiEndpoint -match 'packaging')
            {
                If ($Instance.AbsoluteUri -and $Collection)
                {
                    # Append pkgs prefix to instance without query and api version
                    return '{0}{1}/{2}' -f $Instance.AbsoluteUri.replace($Instance.Host, "pkgs.$($Instance.Host)"), $Collection, $ApiEndpoint
                }
            }
        }
        If ($Instance.AbsoluteUri -and $Collection -and $Project -and $ApiEndpoint -and $ApiVersion -and $Query)
        {
            return '{0}{1}/{2}/{3}?{4}&api-version={5}' -f $Instance.AbsoluteUri, $Collection, $Project, $ApiEndpoint, $Query, $ApiVersion
        }
        If ($Instance.AbsoluteUri -and $Collection -and $ApiEndpoint -and $ApiVersion -and $Query)
        {
            return '{0}{1}/{2}?{3}&api-version={4}' -f $Instance.AbsoluteUri, $Collection, $ApiEndpoint, $Query, $ApiVersion
        }
        ElseIf ($Instance.AbsoluteUri -and $Collection -and $Project -and $ApiEndpoint -and $ApiVersion)
        {
            return '{0}{1}/{2}/{3}?api-version={4}' -f $Instance.AbsoluteUri, $Collection, $Project, $ApiEndpoint, $ApiVersion
        }
        ElseIf ($Instance.AbsoluteUri -and $Collection -and $ApiEndpoint -and $ApiVersion)
        {
            return '{0}{1}/{2}?api-version={3}' -f $Instance.AbsoluteUri, $Collection, $ApiEndpoint, $ApiVersion
        }
        ElseIf ($Instance.AbsoluteUri -and $ApiEndpoint)
        {
            return '{0}{1}' -f $Instance.AbsoluteUri, $ApiEndpoint
        }
    }

    end
    {
    }
}
