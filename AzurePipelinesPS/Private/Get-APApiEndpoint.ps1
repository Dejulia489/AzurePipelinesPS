function Get-APApiEndpoint
{    
    <#
    .SYNOPSIS

    Returns the api uri endpoint.

    .DESCRIPTION

    Returns the api uri endpoint base on the api type.

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
            'build-builds'
            {
                Return '_apis/build/builds'
            }
            'build-buildId'
            {
                Return '_apis/build/builds/{0}'
            }
            'build-definitions'
            {
                Return '_apis/build/definitions'
            }
            'build-definitionId'
            {
                Return '_apis/build/definitions/{0}'
            }
            'packages-agent'
            {
                Return '_apis/distributedTask/packages/agent'
            }
            'release-releases'
            {
                Return '_apis/release/releases'
            }
            'release-definitions'
            {
                Return '_apis/release/definitions'
            }
            'release-definitionId'
            {
                Return '_apis/release/definitions/{0}'
            }
            'release-releaseId'
            {
                Return '_apis/release/releases/{0}'
            }
            'release-manualInterventionId'
            {
                Return '_apis/release/releases/{0}/manualinterventions/{1}'
            }
            'release-environmentId'
            {
                Return '_apis/release/releases/{0}/environments/{1}'
            }
            'release-taskId'
            {
                Return '_apis/release/releases/{0}/environments/{1}/deployPhases/{2}/tasks/{3}'
            }
            'distributedtask-queues'
            {
                Return '_apis/distributedtask/queues'
            }
            'distributedtask-deploymentgroups'
            {
                Return '_apis/distributedtask/deploymentgroups'
            }
            'distributedtask-deploymentGroupId'
            {
                Return '_apis/distributedtask/deploymentgroups/{0}'
            }
            'distributedtask-targets'
            {
                Return '_apis/distributedtask/deploymentgroups/{0}/targets'
            }
            'distributedtask-targetId'
            {
                Return '_apis/distributedtask/deploymentgroups/{0}/targets/{1}'
            }
            'distributedtask-variablegroups'
            {
                Return '_apis/distributedtask/variablegroups'
            }
            'distributedtask-variablegroupId'
            {
                Return '_apis/distributedtask/variablegroups/{0}'
            }
            'git-repositories'
            {
                Return '_apis/git/repositories'
            }
            'git-repositoryId'
            {
                Return '_apis/git/repositories/{0}'
            }
            'project-projects'
            {
                Return '_apis/projects'
            }
            'taskgroup-taskgroups'
            {
                Return '_apis/distributedtask/taskgroups'
            }
            'feed-feeds'
            {
                Return '_apis/packaging/feeds'
            }
            'feed-feedId'
            {
                Return '_apis/packaging/feeds/{0}'
            }
            default
            {
                Write-Error "[$($MyInvocation.MyCommand.Name)]: [$ApiType] is not supported" -ErrorAction Stop
            }
        }
    }

    end
    {
    }
}
