function Get-APApiEndpoint
{    
    <#
    .SYNOPSIS

    Returns the api uri endpoint.

    .DESCRIPTION

    Returns the api uri endpoint.
    This function will return the api endpoint for that api type provided.

    .PARAMETER ApiType

    Type of the api endpoint to use.

    .OUTPUTS

    String, The uri endpoint that will be used by Set-APUri.

    .EXAMPLE

    C:\PS> Get-APApiEndpoint -ApiType release-releases

    .LINK

    https://docs.microsoft.com/en-us/rest/api/vsts/?view=vsts-rest-5.0
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]
        $ApiType
    )

    begin
    {
    }

    process
    {
        Switch ($ApiType)
        {
            'packages-agent'
            {
                '_apis/distributedTask/packages/agent'
            }
            'release-release'
            {
                '_apis/Release/releases'
            }
            'release-releaseId'
            {
                '_apis/Release/releases/{0}'
            }
            'release-manualInterventionId'
            {
                '_apis/Release/releases/{0}/manualinterventions/{1}'
            }
            'release-environmentId'
            {
                '_apis/Release/releases/{0}/environments/{1}'
            }
            'release-taskId'
            {
                '_apis/Release/releases/{0}/environments/{1}/deployPhases/{2}/tasks/{3}'
            }
            default
            {
                Write-Error "[$($MyInvocation.MyCommand.Name)]: [$ApiType] is not supported" -ErrorAction Stop
            }
        }
    }

    end
    {
        Return
    }
}
