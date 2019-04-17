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

    Returns the api endpoint for 'release-releases'

    Get-APApiEndpoint -ApiType release-releases

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
            'release-approvals'
            {
                Return '_apis/release/approvals'
            }
            'release-approvalId'
            {
                Return '_apis/release/approvals/{0}'
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
            'feed-packages'
            {
                Return '_apis/packaging/feeds/{0}/packages'
            }
            'feed-packageId'
            {
                Return '_apis/packaging/feeds/{0}/packages/{1}'
            }
            'graph-userId'
            {
                Return '_apis/graph/users/{0}'
            }
            'graph-users'
            {
                Return '_apis/graph/users'
            }
            'graph-groupId'
            {
                Return '_apis/graph/groups/{0}'
            }
            'graph-groups'
            {
                Return '_apis/graph/groups'
            }
            'graph-storagekeys'
            {
                Return '_apis/graph/storagekeys/{0}'
            }
            'groupentitlements-entitlements'
            {
                Return '_apis/groupentitlements'
            }
            'team-teams'
            {
                Return '_apis/teams'
            }
            'git-deletedrepositories'
            {
                Return '_apis/git/deletedrepositories'
            }
            'git-recycleBin'
            {
                Return '_apis/git/recycleBin/repositories'
            }
            'git-items'
            {
                Return '_apis/git/repositories/{0}/items'
            }
            'extensionmanagement-installedextensions'
            {
                Return '_apis/extensionmanagement/installedextensions'
            }
            'extensionmanagement-installedextensionsbyname'
            {
                Return '_apis/extensionmanagement/installedextensionsbyname/{0}/{1}'
            }
            'dashboard-dashboards'
            {
                Return '_apis/dashboard/dashboards'
            }
            'dashboard-dashboardId'
            {
                Return '_apis/dashboard/dashboards/{0}'
            }
            'dashboard-widgets'
            {
                Return '_apis/dashboard/dashboards/{0}/widgets'
            }
            'dashboard-widgetId'
            {
                Return '_apis/dashboard/dashboards/{0}/widgets/{1}'
            }
            'packaging-feedName'
            {
                Return '_packaging/{0}/nuget/v2'
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
